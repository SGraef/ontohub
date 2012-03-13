class OntologyUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # XML is white-listed here to avoid another Uploader.
  def extension_white_list
    %w(owl clif) + %w(xml)
  end
end