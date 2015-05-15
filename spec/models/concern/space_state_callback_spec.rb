require 'rails_helper'

describe SpaceStateCallback do
  context 'field space_size' do
    before{
      @user = User.create
    }

    describe "@user upload a @image" do
      before{
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
      }

      it{
        @user.space_size.should == @filesize
      }

      it{
        @image.destroy
        @user.space_size.should == 0
      }
    end

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

  it{
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
      is_oss: true
    )
    @image.destroy.should == true
  }

  it "image with @user and string filesize should not be raise" do
    @user = create(:user)
    create(:image_with_str_filesize, user: @user).should be_valid
  end
end
