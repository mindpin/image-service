require 'rails_helper'

describe SpaceState do
  context 'field space_size' do
    before{
      @user = User.create
    }

    it{
      @user.qiniu_image_space_size.should == 0
      @user.av_space_size.should == 0
      
    }

    it{
      @user.recount_space_size.should == true
      @user.qiniu_image_space_size.should == 0
      @user.av_space_size.should == 0
    }
  end
end
