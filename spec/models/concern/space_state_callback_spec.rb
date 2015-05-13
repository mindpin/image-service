require 'rails_helper'

describe SpaceStateCallback do
  context 'field space_size' do
    before{
      @user = User.create
    }

    it{
      @filesize = 219350
      @image = Image.create!(
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
          "filesize" => @filesize
        },
        is_oss: true,
        user: @user
      )
      @user.space_size.should == @filesize
    }

    it{
      @filesizes = 10.times.map{rand(10000)}
      @filesizes.each do |filesize|
        @image = @user.images.create!(
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
            "filesize" => filesize
          },
          is_oss: true
        )
      end
      @user.space_size.should == @filesizes.sum
    }


  end
end

