class ImageSizesController < ApplicationController
  def index
    image_sizes_hash = current_user.image_sizes.map(&:to_hash)
    render json: image_sizes_hash
  end

  def create
    image_size = current_user.image_sizes.create!(
      style:  params[:style],
      width:  params[:width],
      height: params[:height]
    )
    render json: image_size.to_hash
  end

  def destroy
    image_size = current_user.image_sizes.find(params[:id])
    image_size.destroy
    render json: {:text => 'destroy success'}
  end
end
