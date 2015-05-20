require "rails_helper"

RSpec.describe Mkzip, type: :lib do
  describe "2 images upload to qiniu" do
    before do
      @images = []
      @images << Image.from_qiniu_callback_body(:bucket =>"ddtest", :key =>"/i/akmx07Ma.jpg", :fsize =>"138532", :endUser =>"55516eef6368652b5e000000", :imageAve =>"{\"RGB\":\"0x837a71\"}", :origin_file_name =>"thumb_meitu_1.jpg", :mimeType =>"image/jpeg", :imageInfo =>"{\"format\":\"jpeg\",\"width\":563,\"height\":560,\"colorModel\":\"ycbcr\"}")
      @images << Image.from_qiniu_callback_body(:bucket =>"ddtest", :key =>"/i/kOgScBiu.jpg", :fsize =>"325701", :endUser =>"55516eef6368652b5e000000", :imageAve =>"{\"RGB\":\"0x83776a\"}", :origin_file_name =>"thumb.jpg", :mimeType =>"image/jpeg", :imageInfo =>"{\"format\":\"jpeg\",\"width\":563,\"height\":1000,\"colorModel\":\"ycbcr\"}")
      @mkzip = Mkzip.new @images.map{|image| image.id.to_s}
    end

    it "#build_fops" do
      @mkzip.build_fops.should == "mkzip/2/url/#{Base64.encode64(@images.first.url)}/alias/#{Base64.encode64(@images.first.filename)}/url/#{Base64.encode64(@images.last.url)}/alias/#{Base64.encode64(@images.last.filename)}"
    end

    it "#zip" do
      result = @mkzip.zip
      result.class.name.should == "String"
      result.length.should == 24
    end

    it ".result" do
      result = Mkzip.result @mkzip.zip
      result[0].should == 200
      p "result[1]['code']: #{result[1]['code']}"
      [0 ,1].should include(result[1]['code'])
    end
  end
end
