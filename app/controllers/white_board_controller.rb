class WhiteBoardController < ApplicationController
  def show
    @file_entity = FileEntity.find params[:id]
  end
end