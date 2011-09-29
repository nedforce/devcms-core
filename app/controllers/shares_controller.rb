class SharesController < ApplicationController
  before_filter :find_node, :only => [ :new, :create ]
  before_filter :find_page, :only => [ :new, :create ]

  def new
    @share = Share.new(:message => "#{@page.title}: http://#{request.host}/#{@page.node.url_alias}")
  end

  def create
    if params[:share].present? && params[:node_id].present?
      params[:share][:node_id] = params[:node_id]
    end

    @share = Share.new(params[:share])
    if verify_recaptcha(:model => @share) && @share.valid?
      flash[:notice] = I18n.t('share.recommendation_successful')
      @share.send_recommendation_email
      redirect_to content_node_path(@node)
    else
      render :new
    end
  end

  protected

  def find_page
    if @node.present?
      @page = @node.content
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
