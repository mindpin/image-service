class WhiteBoardController < ApplicationController
  def show
    return render "/home/login" if !user_signed_in?
    @file_entity = FileEntity.find params[:id]
  end

  def get_image_comments
    @file_entity = FileEntity.find params[:id]
    hash = @file_entity.image_comments.map(&:to_hash)
    render json: hash
  end

  def create_image_comment
    @file_entity  = FileEntity.find params[:id]
    image_comment = @file_entity.image_comments.create(
      :user    => current_user,
      :x       => params[:x],
      :y       => params[:y],
      :text => params[:text]
    )
    render json: image_comment.to_hash
  end

  def destroy_image_comment
    @file_entity  = FileEntity.find params[:id]
    image_comment = @file_entity.image_comments.find(params[:image_comment_id])
    if image_comment.user == current_user
      image_comment.destroy
      render json: {:status => 200}
      return
    end
    
    render :status => 500
  end
end
