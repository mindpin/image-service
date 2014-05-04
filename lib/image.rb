# coding: utf-8
require "./lib/image_uploader"
require "./lib/workers"
require "backgrounder/orm/activemodel"

class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  extend CarrierWave::Backgrounder::ORM::ActiveModel

  field :file,     type: String
  field :original, type: String
  field :token,    type: String
  field :versions, type: Array
  field :file_processing, type: Boolean
  field :mime,     type: String

  validate :file, :original, :filename, presence: true

  mount_uploader :file, ImageUploader

  process_in_background :file, ProcessWorker

  alias :old_vers :versions

  def self.from_params(hash)
    ImageUploader.apply_settings!
    image = self.new(token: randstr, original: hash[:filename])
    image.file = hash[:tempfile]
    image.mime = hash[:type]
    image.versions = image.file.version_names
    image.save
    image
  end

  def filename
    "#{token}#{File.extname(original).downcase}"
  end

  def versions
    [raw].concat(old_vers.map do |version|
      Version.new(self, version)
    end)
  end

  def raw
    Version.new(self, nil)
  end

  class Version
    attr_reader :name, :value, :url

    def initialize(image, version_def)
      array  = version_def ? version_def.to_s.split("_") : []
      name   = array.select {|i| i.match /[a-zA-Z]+/}.join("_").to_sym
      @name  = name.blank? ? :raw : name
      @image = image
      @value = array.select {|i| i.match /[0-9]+/}.map(&:to_i)
      @url   = image.file.url(version_def)
    end

    def cn
      OutputSettings.names[name] || "原始图片"
    end

    def html
      %Q|<img src="#{url}" />|
    end

    def markdown
      %Q|![](#{url})|
    end
  end
end
