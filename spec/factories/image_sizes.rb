FactoryGirl.define do
  factory :image_size do
    factory :image_size_width do
      style "width"
      width 640
      factory :image_size_width_height do
        style "width_height"
        height 480
      end
    end
    factory :image_size_height do
      style "height"
      height 480
    end
  end
end

