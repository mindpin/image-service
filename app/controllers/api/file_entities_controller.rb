class Api::FileEntitiesController < ApplicationController
  before_filter :set_access_control_headers
  skip_before_filter :verify_authenticity_token

  def set_access_control_headers
    if !request.headers["Origin"].blank?
      response.headers['Access-Control-Allow-Origin']   = request.headers["Origin"]
    end
  end

  def input_from_remote_url_to_quene
    quene_status_id = QueneStatus.create.id.to_s
    current_user_id = current_user.blank? ? "" : current_user.id
    FromRemoteUrlWorker.perform_async(params[:url], current_user_id.to_s, quene_status_id)
    render json: {
      token: quene_status_id
    }
  end

  def get_from_remote_url_status
    quene_status = QueneStatus.find(params[:token])
    case true
    when quene_status.status.processing?
      render json: {status: 'processing'}
    when quene_status.status.failure?
      render json: {status: 'failure'}
    when quene_status.status.success?
      file_entity_id = quene_status.success_data["file_entity_id"]
      file_entity = FileEntity.find(file_entity_id)
      render json: {
        status: 'success',
        data: {
          id: file_entity.id.to_s,
          kind: file_entity.kind,
          url: file_entity.url
        }
      }
    end

  end

end