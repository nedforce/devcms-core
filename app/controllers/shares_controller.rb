class SharesController < ApplicationController
  skip_before_action :find_node
  before_action :find_share_node
  before_action :find_page

  # SSL encryption is required for these actions:
  ssl_required :new, :create

  def new
    @share = Share.new(message: "#{@page.title}: http://#{request.host}/#{@page.node.url_alias}")
  end

  def create
    if params[:share].present? && params[:node_id].present?
      params[:share][:node_id] = params[:node_id]
    end

    @share = Share.new(permitted_attributes)
    if verify_recaptcha(model: @share) && @share.valid?
      flash[:notice] = I18n.t('share.recommendation_successful')
      @share.send_recommendation_email
      redirect_to content_node_path(@node)
    else
      render :new
    end
  end

  protected

  def permitted_attributes
    params.fetch(:share, {}).permit!
  end

  def find_share_node
    @node = current_site.self_and_descendants.accessible.include_content.where(id: params[:node_id]).first!
  end

  def find_page
    @page = @node.content
  end
end
