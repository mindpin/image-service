class ImageSizesController < ApplicationController
  def index
    if current_user
      image_sizes_hash = current_user.image_sizes.map(&:to_hash)
      render json: image_sizes_hash
      return
    end

    render json: []
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
