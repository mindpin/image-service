class HomeController < ApplicationController
  before_filter :render_landing, :except => [:zmkm, :zmkm_aliyun]

  def render_landing
    if not user_signed_in?
      @body_class = 'landing'
      render 'home/landing'
    end
  end

  def index
    per_page = 20
    condition = params[:less_than_id] ? {:id.lt => params[:less_than_id]} : {}
    @images = current_user.file_entities.images
      .is_qiniu
      .where(condition)
      .limit(per_page)
  end

  def aliyun
    per_page = 40
    condition = params[:less_than_id] ? {:id.lt => params[:less_than_id]} : {}
    @images = current_user.file_entities.images
      .is_oss
      .where(condition)
      .limit(per_page)
  end

  def zmkm
    per_page = 20
    condition = params[:less_than_id] ? {:id.lt => params[:less_than_id]} : {}
    @images = FileEntity.anonymous.images
      .is_qiniu
      .where(condition)
      .limit(per_page)
  end

  def zmkm_aliyun
    per_page = 40
    condition = params[:less_than_id] ? {:id.lt => params[:less_than_id]} : {}
    @images = FileEntity.anonymous.images
      .is_oss
      .where(condition)
      .limit(per_page)

    render 'aliyun'
  end
end