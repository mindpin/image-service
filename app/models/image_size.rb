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
      return errors.add(:width, :format_error) if width.nil?
      return errors.add(:height, :format_error) if height.nil?
    when 'width'
      return errors.add(:width, :format_error) if width.nil?
      return errors.add(:height, :format_error) if !height.nil?
    when 'height'
      return errors.add(:width, :format_error) if !width.nil?
      return errors.add(:height, :format_error) if height.nil?
    end
  end
end
