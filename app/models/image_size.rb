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