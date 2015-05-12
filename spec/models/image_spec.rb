require "rails_helper"

RSpec.describe Image, type: :model do
  it "test" do
    image = Image.create!(
      file: "FlsElzV4.png", 
      original: "paste-1431337971644.png", 
      token: "FlsElzV4", 
      mime: "image/png", 
      meta: {
        "major_color" => {
          "rgba" => "rgba(164,166,168,1)", 
          "hex"  => "#A4A6A8"
        }, 
        "height"   => 2001, 
        "width"    => 1125, 
        "filesize" => 219350
      },
      is_oss: true
    )
    
    expect(image.original).to eq("paste-1431337971644.png")
    expect(image.base).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png")
  end
end