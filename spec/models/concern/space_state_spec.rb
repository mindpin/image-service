require 'rails_helper'

describe SpaceState do
  context 'field space_size' do
    before{
      @user = User.create
    }

    it{
      @user.space_size.should == 0
    }

    it{
      @user.recount_space_size.should == true
      @user.space_size.should == 0
    }
  end
end
