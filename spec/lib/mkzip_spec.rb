require "rails_helper"

RSpec.describe Mkzip, type: :lib do
  describe "2 images upload to qiniu" do
    before do
      @images = []
      @images << create(:first_image)
      @images << create(:second_image)
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
      [0 ,1].should include(result[1]['code'])
    end

    # todo
    #it "download zip and unpack, with includes first.jpg and second.jpg" do
    #end
  end
end
