# frozen_string_literal: true

# API Controller for resources of Invoice and Avoir
class API::InvoicesController < API::ApiController
  before_action :authenticate_user!
  before_action :set_invoice, only: %i[show download]

  def index
    authorize Invoice
    @invoices = Invoice.includes(
      :avoir, :invoiced, invoice_items: %i[subscription invoice_item], user: %i[profile trainings]
    ).all.order('reference DESC')
  end

  def download
    authorize @invoice
    send_file File.join(Rails.root, @invoice.file), type: 'application/pdf', disposition: 'attachment'
  end

  def list
    authorize Invoice

    p = params.require(:query).permit(:number, :customer, :date, :order_by, :page, :size)

    render json: { error: 'page must be an integer' }, status: :unprocessable_entity and return unless p[:page].is_a? Integer

    render json: { error: 'size must be an integer' }, status: :unprocessable_entity and return unless p[:size].is_a? Integer

    order = InvoicesService.parse_order(p[:order_by])
    @invoices = InvoicesService.list(
      order[:order_key],
      order[:direction],
      p[:page],
      p[:size],
      number: p[:number], customer: p[:customer], date: p[:date]
    )
  end

  # only for create refund invoices (avoir)
  def create
    authorize Invoice
    invoice = Invoice.only_invoice.find(avoir_params[:invoice_id])
    @avoir = invoice.build_avoir(avoir_params)
    if @avoir.save
      # when saved, expire the subscription if needed
      @avoir.expire_subscription if @avoir.subscription_to_expire
      # then answer the API call
      render :avoir, status: :created
    else
      render json: @avoir.errors, status: :unprocessable_entity
    end
  end

  private

  def avoir_params
    params.require(:avoir).permit(:invoice_id, :avoir_date, :avoir_mode, :subscription_to_expire, :description,
                                  invoice_items_ids: [])
  end

  def set_invoice
    @invoice = Invoice.find(params[:id])
  end
end
