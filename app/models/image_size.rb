class ImageSize
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Enumerize

  field :style, type: String
  field :width, type: Integer
  field :height, type: Integer

  enumerize :style, in: [:width_height, :width, :height], default: :width_height

  validates_presence_of :style
  validates :width, numericality: { only_integer: true }, allow_nil: true
  validates :height, numericality: { only_integer: true }, allow_nil: true

  belongs_to :user

  scope :anonymous, -> { where(user_id: nil)}

  def name
    case style
    when 'width_height'
      "宽度 #{width}px, 高度 #{height}px"
    when 'width'
      "宽度 #{width}px, 高度自适应"
    when 'height'
      "高度 #{height}px, 宽度自适应"
    end
  end

  def to_hash
    {
      id: self.id.to_s,
      style: self.style,
      width: self.width,
      height: self.height,
      name: self.name
    }
  end

  protected
  validate :validate_style_and_size
  def validate_style_and_size
    case style
    when 'width_height'
      errors.add(:width, :format_error) if width.nil?
      errors.add(:height, :format_error) if height.nil?
    when 'width'
      errors.add(:width, :format_error) if width.nil?
      errors.add(:height, :format_error) if !height.nil?
    when 'height'
      errors.add(:width, :format_error) if !width.nil?
      errors.add(:height, :format_error) if height.nil?
    end
  end

  module FileEntityMethods
    def self.included(base)

      base.send(:extend, ClassMethods)
    end

    def versions
      if self.user.blank?
        image_sizes = ImageSize.anonymous
      else
        image_sizes = self.user.image_sizes
      end
      result = image_sizes.map{|image_size| ImageVersion.new(self, image_size)}
      result.unshift(ImageVersion.new(self, nil))
    end

    def version(image_size_id)
      if self.user.blank?
        image_sizes = ImageSize.anonymous
      else
        image_sizes = self.user.image_sizes
      end
      ImageVersion.new(self, image_sizes.find(image_size_id))
    end

    module ClassMethods
      def images_versions(file_entity_ids, image_size_id)
        find(file_entity_ids).map{|file_entity| file_entity.version(image_size_id)}
      end

      def images_to_html_by_ids_and_image_size_id(file_entity_ids, image_size_id)
        find(file_entity_ids).map{|file_entity| file_entity.version(image_size_id)}.map(&:to_html)
      end
    end
  end

end
