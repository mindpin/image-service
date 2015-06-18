# coding: utf-8
class FileEntity
  KINDS = [:image, :audio, :video]
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize
  include SpaceStateCallback
  include FileEntityCreateMethods
  include ImageSize::FileEntityMethods
  include TranscodingRecord::FileEntityMethods
  include ImageComment::FileEntityMethods

  field :original, type: String
  field :token,    type: String
  field :qiniu_key,type: String
  field :mime,     type: String
  field :meta,     type: Hash
  field :is_oss,   type: Boolean
  field :kind,     type: String

  belongs_to :user
  default_scope -> {order(:id => :desc)}
  scope :anonymous, -> {where(:user_id => nil)}
  scope :images, -> {where(:kind => :image)}
  scope :avs,    -> {where(:kind.in => [:audio, :video])}
  scope :is_oss, -> {where(:is_oss => true)}
  scope :is_qiniu, -> {where(:is_oss => nil)}
  validates :original, :mime, :meta, presence: true
  enumerize :kind, in: KINDS

  validate :check_token_and_qiniu_key
  def check_token_and_qiniu_key
    if is_oss && token.blank?
      errors.add(:token, "token 不能为空")
    elsif !is_oss && qiniu_key.blank?
      errors.add(:qiniu_key, "qiniu_key 不能为空")
    end
  end

  def filesize
    self.meta["filesize"].to_i
  end

  def ave
    self.meta["major_color"]["hex"]
  end

  def width
    self.meta["width"]
  end

  def height
    self.meta["height"]
  end

  # key 去掉 ext
  def key_prefix
    arr = qiniu_key.split(".")
    arr.pop
    arr.join(".")
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
      File.join(ENV['QINIU_DOMAIN'], self.qiniu_key)
    end
  end

  # 此方法暂时没有地方用到了
  def path
    if self.is_oss?
      File.join("/",ENV['ALIYUN_BASE_DIR'],
                "#{filename}")
    else
      if self.qiniu_key[0] == "@"
        return self.qiniu_key.gsub("@","")
      end
      return self.qiniu_key
    end
  end


end
