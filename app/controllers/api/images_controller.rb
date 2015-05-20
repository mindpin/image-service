class Api::ImagesController < ApplicationController
  before_filter :set_access_control_headers
  skip_before_filter :verify_authenticity_token, only: :from_remote_url

  def set_access_control_headers
    if !request.headers["Origin"].blank?
      response.headers['Access-Control-Allow-Origin']   = request.headers["Origin"]
    end
  end

  def from_remote_url
    image = Image.from_remote_url(params[:url], current_user)
    render json: {
      id: image.id.to_s,
      is_image: image.is_image?,
      url: image.url
    }
  rescue Exception => e
    p e.message
    puts e.backtrace*"\n"
    render :status => 500, :json => {:status => 'error'}
  end

end