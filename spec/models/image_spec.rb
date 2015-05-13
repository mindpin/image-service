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
      expect(@image.url).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png")

      origin_version = @image.versions.first
      expect(origin_version.name).to eq("原始图片")
      expect(origin_version.url).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png")
    }

    context 'versions' do
      it{
        ImageSize.create(style: :width_height, width: 500, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度 500px")
        expect(version.url).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png@500w_500h_1e_1c.png")   
      }

      it {
        ImageSize.create(style: :width, width: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度按比例缩放")
        expect(version.url).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png@500w.png")   
      }

      it{
        ImageSize.create(style: :height, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("高度 500px，宽度按比例缩放")
        expect(version.url).to eq("http://zzz-dev.oss-cn-qingdao.aliyuncs.com/aaa/FlsElzV4.png@500h.png")   
      }
    end

  end

  context 'new qiniu yun image' do
    before{
      callback_body = {
        bucket: "fushang318", 
        key: "/i/IuR0fINf.jpg", 
        fsize: "25067", 
        imageAve: "{\"RGB\":\"0x4f4951\"}", 
        origin_file_name: "1-120GQF34TY.jpg", 
        mimeType: "image/jpeg", 
        imageInfo: "{\"format\":\"jpeg\",\"width\":200,\"height\":200,\"colorModel\":\"ycbcr\"}"
      }

      @image = Image.from_qiniu_callback_body(callback_body)
    }

    it{
      expect(@image.original).to eq("1-120GQF34TY.jpg")
      expect(@image.url).to eq("http://7xie1v.com1.z0.glb.clouddn.com/@/i/IuR0fINf.jpg")

      origin_version = @image.versions.first
      expect(origin_version.name).to eq("原始图片")
      expect(origin_version.url).to eq("http://7xie1v.com1.z0.glb.clouddn.com/@/i/IuR0fINf.jpg")
    }

    context 'versions' do
      it{
        ImageSize.create(style: :width_height, width: 500, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度 500px")
        expect(version.url).to eq("http://7xie1v.com1.z0.glb.clouddn.com/@/i/IuR0fINf.jpg?imageView2/1/w/500/h/500")   
      }

      it {
        ImageSize.create(style: :width, width: 500)
        version = @image.versions.last
        expect(version.name).to eq("宽度 500px，高度按比例缩放")
        expect(version.url).to eq("http://7xie1v.com1.z0.glb.clouddn.com/@/i/IuR0fINf.jpg?imageView2/2/w/500")   
      }

      it{
        ImageSize.create(style: :height, height: 500)
        version = @image.versions.last
        expect(version.name).to eq("高度 500px，宽度按比例缩放")
        expect(version.url).to eq("http://7xie1v.com1.z0.glb.clouddn.com/@/i/IuR0fINf.jpg?imageView2/2/h/500")   
      }
    end
  end
end