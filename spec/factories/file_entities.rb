FactoryGirl.define do
  factory :file_entity do
    original "test.jpg"
    sequence(:token) {|n| "test#{n}"}
    mime "image/jpeg"
    kind "image"
    meta "major_color" => { "rgba" => "rgba(164,166,168,1)", "hex" => "#A4A6A8" }, "height" => "2001", "width" => "1125", "filesize" => 219350
    factory :image_is_oss do
      is_oss true
    end

    factory :image_with_str_filesize do
      meta "major_color" => { "rgba" => "rgba(164,166,168,1)", "hex" => "#A4A6A8" }, "height" => "2001", "width" => "1125", "filesize" => "219350"
    end

    factory :first_image do
      original "first.jpg"
      token "first"
      mime "image/jpeg"
      meta "major_color" => {"rgba"=>"rgba(131,122,113,0)", "hex"=>"#837a71"}, "height" => "560", "width" => "563", "filesize" => "138532"
    end

    factory :second_image do
      original "second.jpg"
      token "second"
      mime "image/jpeg"
      meta "major_color" => {"rgba"=>"rgba(192,196,187,0)", "hex"=>"#c0c4bb"}, "height" => "480", "width" => "320", "filesize" => "29843"
    end
  end
end

