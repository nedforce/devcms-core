# This +RESTful+ controller is used to orchestrate and control the flow of
# the application relating to +WeblogArchive+ objects.
class Admin::WeblogArchivesController < Admin::AdminController

  # The +create+ action needs the parent +Node+ object to link the new +WeblogArchive+ content node to.
  prepend_before_filter :find_parent_node, :only => [ :new, :create ]

  # The +show+, +edit+ and +update+ actions need a +WeblogArchive+ object to act upon.
  before_filter :find_weblog_archive,      :only => [ :show, :edit, :update ]

  before_filter :find_weblogs,             :only => :show

  before_filter :set_commit_type,          :only => [ :create, :update ]

  layout false

  require_role [ 'admin' ], :except => [ :index, :show ]

  # * GET /admin/weblog_archives.json?node=1&active_node_id=2
  #
  # *parameters*
  #
  # +node+           - Id of the node of which the children are requested
  # +super_node+     - Id of the node of which the children are requested, when also an offset is specified.
  # +active_node_id+ - (Optional) Id of the active node. If the active node is contained by this weblog archive, the containing offset-node will auto-expand.
  def index
    respond_to do |format|
      node_id              = params[:super_node] || params[:node]
      @weblog_archive_node = Node.find(node_id)

      active_node          = params[:active_node_id] ? Node.find(params[:active_node_id]) : nil
      @offset              = WeblogArchive.parse_offset(params[:offset].to_i) if params[:offset]

      format.json do
        if @offset
          @weblog_nodes = @weblog_archive_node.content.find_weblogs_for_offset(@offset).map(&:node)
          render :json => @weblog_nodes.map { |node| node.to_tree_node_for(current_user, :expand_if_ancestor_of => active_node) }.to_json
        else
          @archive_includes_active_node = active_node ? @weblog_archive_node.descendants.include?(active_node) : false

          @offset_nodes = @weblog_archive_node.content.find_offsets.map do |offset|
            # Not too keen on these extra queries here, is there another way to accomplish this?
            first_weblog, last_weblog = @weblog_archive_node.content.find_first_and_last_weblog_for_offset(offset)

            active_content = active_node.content if active_node
            if active_node && (active_content.is_a? Weblog)
              range_includes_active_node = @archive_includes_active_node && (first_weblog.title <= active_content.title && active_content.title <= last_weblog.title)
            elsif active_node && (active_content.is_a? WeblogPost)
              title = active_node.parent.content.title
              range_includes_active_node = @archive_includes_active_node && (first_weblog.title <= title && title <= last_weblog.title)
            else
              range_includes_active_node = false
            end

            {
              :treeLoaderName => Node.content_type_configuration('WeblogArchive')[:tree_loader_name],
              :text           => "#{first_weblog.title[0..1].titleize} - #{last_weblog.title[0..1].titleize}",
              :expanded       => range_includes_active_node,
              :extraParams    => {
                :super_node => node_id,
                :offset     => offset
              }
            }
          end

          render :json => @offset_nodes.to_json
        end
      end
    end
  end

  # * GET /admin/weblog_archives/:id
  # * GET /admin/weblog_archives/:id.xml
  def show
    @actions = nil if !current_user.has_role?('admin') # no-one else should have an edit button

    respond_to do |format|
      format.html { render :partial => 'show', :layout => 'admin/admin_show' }
      format.xml  { render :xml => @weblog_archive }
    end
  end

  # * GET /admin/weblog_archives/new
  def new
    @weblog_archive = WeblogArchive.new(params[:weblog_archive])

    respond_to do |format|
      format.html { render :template => 'admin/shared/new', :locals => { :object => @weblog_archive }}
    end
  end

  # * GET /admin/weblog_archives/:id/edit
  def edit
    @weblog_archive.attributes = params[:weblog_archive]

    respond_to do |format|
      format.html { render :template => 'admin/shared/edit', :locals => { :object => @weblog_archive }}
    end
  end

  # * POST /admin/weblog_archives
  # * POST /admin/weblog_archives.xml
  def create
    @weblog_archive        = WeblogArchive.new(params[:weblog_archive])
    @weblog_archive.parent = @parent_node

    respond_to do |format|
      if @commit_type == 'preview' && @weblog_archive.valid?
        format.html { render :template => 'admin/shared/create_preview', :locals => { :object => @weblog_archive }, :layout => 'admin/admin_preview' }
        format.xml  { render :xml => @weblog_archive, :status => :created, :location => @weblog_archive }
      elsif @commit_type == 'save' && @weblog_archive.save
        format.html { render :template => 'admin/shared/create' }
        format.xml  { render :xml => @weblog_archive, :status => :created, :location => @weblog_archive }
      else
        format.html { render :template => 'admin/shared/new', :locals => { :object => @weblog_archive }, :status => :unprocessable_entity }
        format.xml  { render :xml => @weblog_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

  # * PUT /admin/weblog_archives/:id
  # * PUT /admin/weblog_archives/:id.xml
  def update
    @weblog_archive.attributes = params[:weblog_archive]

    respond_to do |format|
      if @commit_type == 'preview' && @weblog_archive.valid?
        format.html {
          find_weblogs
          render :template => 'admin/shared/update_preview', :locals => { :object => @weblog_archive }, :layout => 'admin/admin_preview'
        }
        format.xml  { render :xml => @weblog_archive, :status => :created, :location => @weblog_archive }
      elsif @commit_type == 'save' && @weblog_archive.save
        format.html { render :template => 'admin/shared/update' }
        format.xml  { head :ok }
      else
        format.html { render :template => 'admin/shared/edit', :locals => { :object => @weblog_archive }, :status => :unprocessable_entity }
        format.xml  { render :xml => @weblog_archive.errors, :status => :unprocessable_entity }
      end
    end
  end

protected

  # Finds the +WeblogArchive+ object corresponding to the passed in +id+ parameter.
  def find_weblog_archive
    @weblog_archive = WeblogArchive.find(params[:id], :include => [:node])
  end

  def find_weblogs
    @weblogs = @weblog_archive.weblogs.find_accessible(:all, :for => current_user, :page => { :current => 1 })
  end
end
