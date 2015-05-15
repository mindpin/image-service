FactoryGirl.define do
  factory :image do
    original "test.jpg"
    sequence(:token) {|n| "test#{n}"}
    mime "image/jpeg"
    meta "major_color" => { "rgba" => "rgba(164,166,168,1)", "hex" => "#A4A6A8" }, "height" => "2001", "width" => "1125", "filesize" => "219350"
    factory :image_is_oss do
      is_oss true
    end
  end
end

