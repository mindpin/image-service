# coding: utf-8
class FileEntity
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize
  include SpaceStateCallback
  include FileEntityCreateMethods
  include ImageSize::FileEntityMethods
  include TranscodingRecord::FileEntityMethods

  field :original, type: String
  field :token,    type: String
  field :mime,     type: String
  field :meta,     type: Hash
  field :is_oss,   type: Boolean
  field :kind,     type: String

  belongs_to :user
  scope :anonymous, -> {where(:user_id => nil)}
  validates :original, :token, :mime, :meta, presence: true
  enumerize :kind, in: [:image, :audio, :video]

  def filesize
    self.meta["filesize"].to_i
  end

  def key
    File.join("/", ENV["QINIU_BASE_PATH"], filename)
  end

  # key 去掉 ext
  def key_prefix
    File.join("/", ENV["QINIU_BASE_PATH"], token)
  end

  def filename
    "#{token}#{ext}"
  end

  def ext
    File.extname(original).downcase
  end

  def url
    if self.is_oss?
      File.join(ENV['IMAGE_ENDPOINT'],
                ENV['ALIYUN_BASE_DIR'],
                "#{filename}")
    else
      self.class._get_qiniu_url(filename)
    end
  end

  def path
    if self.is_oss?
      File.join("/",ENV['ALIYUN_BASE_DIR'],
                "#{filename}")
    else
      File.join("/",ENV['QINIU_BASE_PATH'],
                "#{filename}")
    end
  end

  def self._get_qiniu_url(filename)
    File.join(ENV['QINIU_DOMAIN'],
              "@",
              ENV['QINIU_BASE_PATH'],
              "#{filename}")
  end

end
