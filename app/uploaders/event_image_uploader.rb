# frozen_string_literal: true

# CarrierWave uploader for images illustrating the Events.
# This file defines the parameters for these uploads.
class EventImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include UploadHelper

  # Choose what kind of storage to use for this uploader:
  storage :file
  after :remove, :delete_empty_dirs
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:

  def store_dir
    "#{base_store_dir}/#{model.id}"
  end

  def base_store_dir
    "uploads/#{model.class.to_s.underscore}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_pack_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :normal do
  #   process :resize_to_fit => [312, 270]
  # end

  version :large do
    process resize_to_fit: [1000, 700]
  end

  version :medium do
    process resize_to_fit: [700, 400]
  end

  version :small do
    process resize_to_fit: [260, 260]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w[jpg jpeg gif png]
  end

  def content_type_whitelist
    [%r{image/}]
  end


  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.class.to_s.underscore}.#{file.extension}" if original_filename
  end

  # return an array like [width, height]
  def dimensions
    ::MiniMagick::Image.open(file.file)[:dimensions]
  end
end
