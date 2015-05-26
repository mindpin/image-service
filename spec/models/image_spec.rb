require "rails_helper"

RSpec.describe Image, type: :model do
  context 'old aliyun oss image' do
    before{
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
          "filesize" => 219350
        },
        is_oss: true
      )
    }

    it{

      expect(@image.original).to eq("paste-1431337971644.png")
      expect(@image.url).to eq(File.join(ENV['IMAGE_ENDPOINT'], ENV['ALIYUN_BASE_DIR'], 'FlsElzV4.png'))

      origin_version = @image.versions.first
      expect(origin_version.name).to eq("原始图片")
      expect(origin_version.url).to eq(File.join(ENV['IMAGE_ENDPOINT'], ENV['ALIYUN_BASE_DIR'], 'FlsElzV4.png'))
    }

    context 'versions' do
      it{
        ImageSize.create(style: :width_height, width: 500, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度 500px")
        expect(version.url).to eq(File.join(ENV['IMAGE_ENDPOINT'], ENV['ALIYUN_BASE_DIR'], 'FlsElzV4.png@500w_500h_1e_1c.png'))   
      }

      it {
        ImageSize.create(style: :width, width: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度按比例缩放")
        expect(version.url).to eq(File.join(ENV['IMAGE_ENDPOINT'], ENV['ALIYUN_BASE_DIR'], 'FlsElzV4.png@500w.png'))   
      }

      it{
        ImageSize.create(style: :height, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("高度 500px，宽度按比例缩放")
        expect(version.url).to eq(File.join(ENV['IMAGE_ENDPOINT'], ENV['ALIYUN_BASE_DIR'], 'FlsElzV4.png@500h.png'))   
      }
    end

  end

  context 'new qiniu yun image' do
    before{
      callback_body = {
        bucket: "fushang318", 
        key: "/i/IuR0fINf.jpg", 
        fsize: "25067", 
        image_rgb: "0x4f4951", 
        origin_file_name: "1-120GQF34TY.jpg", 
        mimeType: "image/jpeg", 
        image_width: "200",
        image_height: "200"
      }

      @image = Image.from_qiniu_callback_body(callback_body)
    }

    it{
      expect(@image.original).to eq("1-120GQF34TY.jpg")
      expect(@image.url).to eq(File.join(ENV['QINIU_DOMAIN'], '@', ENV['QINIU_BASE_PATH'], 'IuR0fINf.jpg'))
      origin_version = @image.versions.first
      expect(origin_version.name).to eq("原始图片")
      expect(origin_version.url).to eq(File.join(ENV['QINIU_DOMAIN'], '@', ENV['QINIU_BASE_PATH'], 'IuR0fINf.jpg'))
    }

    context 'versions' do
      it{
        ImageSize.create(style: :width_height, width: 500, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度 500px")
        expect(version.url).to eq(File.join(ENV['QINIU_DOMAIN'], '@', ENV['QINIU_BASE_PATH'], 'IuR0fINf.jpg?imageView2/1/w/500/h/500'))   
      }

      it {
        ImageSize.create(style: :width, width: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度按比例缩放")
        expect(version.url).to eq(File.join(ENV['QINIU_DOMAIN'], '@', ENV['QINIU_BASE_PATH'], 'IuR0fINf.jpg?imageView2/2/w/500'))   
      }

      it{
        ImageSize.create(style: :height, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("高度 500px，宽度按比例缩放")
        expect(version.url).to eq(File.join(ENV['QINIU_DOMAIN'], '@', ENV['QINIU_BASE_PATH'], 'IuR0fINf.jpg?imageView2/2/h/500'))   
      }
    end
  end

  describe ImageVersion do
    describe "anonymous" do
      before do
        @images = [create(:image), create(:image)]
        @image_size = create(:image_size_width)
      end

      it "#version(version_id)" do
        @images.each do |image|
          image.version(@image_size.id).should == ImageVersion.new(image, @image_size)
        end
      end

      it "Image.images_versions image_ids, version_id" do
        Image.images_versions(@images.map(&:id), @image_size.id).should == @images.map{|image| image.version(@image_size.id)}
      end

      it "Image.images_to_html_by_ids_and_image_size_id image_ids, version_id" do
        Image.images_to_html_by_ids_and_image_size_id(@images.map(&:id), @image_size.id).should == @images.map{|image| image.version(@image_size.id).to_html}
      end
    end

    describe "by user" do
      before do
        @user = create(:user)
        @images = [create(:image, user: @user), create(:image, user: @user)]
        @image_size = create(:image_size_width, user: @user)
      end

      it "#version(version_id)" do
        @images.each do |image|
          image.version(@image_size.id).should == ImageVersion.new(image, @image_size)
        end
      end

      it "Image.images_versions image_ids, version_id" do
        Image.images_versions(@images.map(&:id), @image_size.id).should == @images.map{|image| image.version(@image_size.id)}
      end

      it "Image.images_to_html_by_ids_and_image_size_id image_ids, version_id" do
        Image.images_to_html_by_ids_and_image_size_id(@images.map(&:id), @image_size.id).should == @images.map{|image| image.version(@image_size.id).to_html}
      end
    end

    describe "#to_html" do
      it "width_height" do
        @image = create(:image)
        @image_size = create(:image_size_width_height)
        p @image_size
        @version = ImageVersion.new(@image, @image_size)
        @version.to_html.should == "<img width='#{@image_size.width}' height='#{@image_size.height}' src='#{@version.url}' />"
      end

      it "width" do
        @image = create(:image)
        @image_size = create(:image_size_width)
        @version = ImageVersion.new(@image, @image_size)
        @version.to_html.should == "<img width='#{@image_size.width}' src='#{@version.url}' />"
      end

      it "height" do
        @image = create(:image)
        @image_size = create(:image_size_height)
        p @image_size
        @version = ImageVersion.new(@image, @image_size)
        @version.to_html.should == "<img height='#{@image_size.height}' src='#{@version.url}' />"
      end
    end
  end
end
