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
      "宽度 #{width}px，高度 #{height}px"
    when 'width'
      "宽度 #{width}px，高度按比例缩放"
    when 'height'
      "高度 #{height}px，宽度按比例缩放"
    end
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

  module ImageMethods
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
      def images_versions(image_ids, image_size_id)
        find(image_ids).map{|image| image.version(image_size_id)}
      end

      def images_to_html_by_ids_and_image_size_id(image_ids, image_size_id)
        find(image_ids).map{|image| image.version(image_size_id)}.map(&:to_html)
      end
    end
  end

end
