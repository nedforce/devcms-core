# This administrative controller is used to manage the website's nodes.
class Admin::NodesController < Admin::AdminController
  before_filter :default_format_json,  :only => :destroy

  # Only allow XHMLHttpRequests some actions.
  before_filter :verify_xhr, :only => [ :move, :move_by_date, :count_children, :sort_children, :set_visibility, :set_accessibility, :export_newsletter ]

  before_filter :find_nodes, :only => [ :bulk_edit, :bulk_update ]

  before_filter :find_images_and_attachments, :only => [ :audit_show, :audit_edit, :previous_diffed ]

  # Require a role for the current node on update, destroy and move
  require_role 'admin', :only => :set_accessibility

  require_role ['admin', 'final_editor'], :except => [ :index, :update, :set_visibility, :set_accessibility, :bulk_edit, :bulk_update, :destroy, :export_newsletter ]

  require_role ['admin', 'final_editor', 'editor'], :only => [ :update, :bulk_edit, :bulk_update, :set_visibility, :destroy, :move, :sort_children, :count_children, :move_by_date ]

  # Shows the sitemap admin page for html requests. The tree's root will be
  # the node with the given id, or the root node if no id is given.
  #
  # For json requests it returns a JSON array of objects with attributes corresponding those
  # of the children of the node with the given id or the root node if
  # no id is given.
  #
  # *parameters*
  #
  # +node+ - id of the node to use as the tree's root for html requests or of which the children are returned for json requests.
  # +active_node_id+ - (Optional) id of the active node.
  #  For HTML: All ancestors of the active node will auto-expand, and the active node itself will be selected.
  #  For JSON: If the currently loaded node is an ancestor of the active node, it will auto-expand.
  #
  # * GET /admin/nodes
  # * GET /admin/nodes?active_node_id=2
  # * GET /admin/nodes?node=1
  # * GET /admin/nodes.json
  # * GET /admin/nodes.json?node=1
  # * GET /admin/nodes.json?active_node_id=2
  def index
    respond_to do |format|
      if params[:node]
        @root_node = Node.find(params[:node])
      else
        @root_node = Node.root
      end
      format.html do
        @active_page = :sitemap
        render :action => 'index' # index.html.erb
      end
      format.json do
        active_node = params.has_key?(:active_node_id) ? Node.find(params[:active_node_id]) : nil
        @nodes = @root_node.children.includes([:content, :role_assignments])
        render :json => @nodes.map { |node| node.to_tree_node_for(current_user, { :expand_if_ancestor_of => active_node }) }.to_json
      end
    end
  end

  # Updates a node's attributes
  # * PUT /admin/nodes/1.json
  # * PUT /admin/nodes/1.xml
  def update
    # Find and set template for this node if given.
    # TODO: Refactor this!
    # Something like @node.templates_for(current_user).find(params[:node][:template_id])
    # that uses a single SQL query and throws a RecordNotFound exception if the template is not
    # available to the given user. Maybe we can use the scope_out plugin or something similar.
    if params[:node] && params[:node][:template_id]
      if params[:node][:template_id] == 'inherit'
        params[:node][:template] = nil
      elsif @node.find_available_templates_for(current_user).map(&:id).include?(params[:node][:template_id].to_i)
        params[:node][:template] = @node.find_available_templates_for(current_user).find { |t| t.id == params[:node][:template_id].to_i }
      else
        raise ActiveRecord::RecordNotFound
      end
      params[:node].delete(:template_id)
    end

    respond_to do |format|
      if @node.update_attributes(permitted_attributes)
        format.xml  { head :ok }
        format.json { render :json => { :success => 'true' } }
      else
        format.xml  { render :xml => @node.errors.to_xml, :status => :unprocessable_entity }
        format.json { render :json => { :errors => @node.errors.full_messages }.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def bulk_edit
  end

  def bulk_update
    respond_to do |format|
      if Node.bulk_update(@nodes, params[:node] || {}, current_user)
        format.html # bulk_update.html.erb
      else
        format.html { render :action => 'bulk_edit' }
      end
    end
  end

  # Destroys a node, and all of its descendants.
  # * DELETE /admin/nodes/1.xml
  # * DELETE /admin/nodes/1.json
  def destroy
    respond_to do |format|
      return access_denied unless current_user.has_role_on?(@node.content_type_configuration[:allowed_roles_for_destroy], @node)

      @node.content_type == 'ContentCopy' ? @node.destroy : @node.paranoid_delete!

      format.xml  { head :ok }
      format.json { render :json => { :notice => I18n.t('nodes.succesfully_destroyed') }.to_json, :status => :ok }
    end
  end

  def bulk_destroy
    respond_to do |format|
      parent_node = Node.find(params[:parent_id])
      return access_denied unless current_user.has_role_on?("admin", parent_node)
      #                                                                                  paranoid_delete
      parent_node.content.destroy_items_for_year_or_month(params[:year], params[:month], true)

      format.xml  { head :ok }
      format.json { render :json => { :notice => I18n.t('nodes.succesfully_destroyed') }.to_json, :status => :ok }
    end
  end


  def export_newsletter
    if @node.content.is_a?(NewsletterArchive)
      respond_to do |format|
        format.json { render :json => { :id => @node.content.id,:notice => I18n.t('nodes.newsletter_subscribers_export') }.to_json, :status => :ok }
      end
    else
      respond_to do |format|
        format.json { render :json => { :error => I18n.t('nodes.newsletter_not_found') }.to_json, :status => :precondition_failed }
      end
    end
  end

  # Sets this node to be the website's (global) frontpage
  # * PUT /admin/nodes/1/make_global_frontpage.json
  # * PUT /admin/nodes/1/make_global_frontpage.xml
  def make_global_frontpage
    respond_to do |format|
      if !@node.visible?
        format.json { render :json => { :error => I18n.t('nodes.frontpage_cant_be_hidden') }.to_json, :status => :precondition_failed }
        format.xml  { head :precondition_failed }
      elsif Node.root.content.set_frontpage!(@node)
        format.json { render :json => { :notice => I18n.t('nodes.frontpage_set') }.to_json, :status => :ok }
        format.xml  { head :ok }
      else
        format.json { render :json => { :error => I18n.t('nodes.frontpage_cant_be_set') }.to_json, :status => :precondition_failed }
        format.xml  { head :precondition_failed }
      end
    end
  end

  # Moves a node within the tree.
  #
  # *parameters*
  # parent - ID of the new parent node for this node.
  # next_sibling - ID of the node which should be to the right of this node.
  #
  # Either next_sibling or parent is used. If both are given parent will be ignored.
  #
  # * XHR PUT /admin/nodes/2/move?parent=1
  # * XHR PUT /admin/nodes/2/move?next_sibling=1
  def move
    begin
      next_sibling = Node.find(params[:next_sibling]) if params[:next_sibling].present?
      parent = Node.find(params[:parent]) if params[:parent].present?

      if next_sibling.present? && (parent.blank? || parent == next_sibling.parent)
        @node.move_to_left_of next_sibling
        render :text => I18n.t('nodes.succesfully_moved'), :status => :ok
      elsif parent.present?
        @node.move_to_child_of parent
        render :text => I18n.t('nodes.succesfully_moved'), :status => :ok
      else
        render :text => I18n.t('nodes.no_parent_or_sibling'), :status => :precondition_failed
      end
    rescue ActiveRecord::ActiveRecordError => e
      render :text => e.message, :status => :unprocessable_entity
    end
  end

  def move_by_date
    begin
      new_parent = Node.find( params[:parent_id] )
      have_same_content_type = (new_parent.content.class == @node.content.class)
      nodes_act_as_archive = [@node, new_parent].all? { |n| n.content.respond_to?(:acts_as_archive_items) }


      if new_parent && have_same_content_type && nodes_act_as_archive
        parse_date_parameters

        content_to_move =
          if @year
            if @month
              @node.content.find_all_items_for_month(@year, @month)
            elsif params[:week]
              @node.content.find_all_items_for_week(@year, params[:week].to_i)
            else
              @node.content.find_all_items_for_year(@year)
            end
          else
            []
          end

        content_to_move.each { |content| content.node.move_to_child_of( new_parent ) }
        render :text => I18n.t('nodes.succesfully_moved'), :status => :ok
      else
        render :text => I18n.t('nodes.different_content_nodes'), :status => :precondition_failed
      end
    rescue ActiveRecord::ActiveRecordError => e
      render :text => e.message, :status => :unprocessable_entity
    end
  end

  # Used for approving content of a given node
  #
  # GET /admin/nodes/1/audit_show
  def audit_show
    @current_url = self.send("admin_#{@node.content_class.name.underscore}_url", @node.content) + '?show_actions=false'

    if @node.content.versioned? && @node.publishable?
      @previous_url = self.send("previous_admin_#{@node.content_class.name.underscore}_url", @node.content) + '?show_actions=false'

      @diff_url = previous_diffed_admin_node_url(@node, :show_actions => false)
    end

    render :action => :audit_show, :layout => false
  end

  # Diffs the current and previous version of a content node.
  # * GET /admin/nodes/:id/previous_diffed
  def previous_diffed
    content           = @node.content
    @content          = content.current_version
    @previous_content = content.previous_version || @content
    @controller_path  = content.controller_name
  end

  # Handles a normal edit in a side panel
  # GET /admin/nodes/:id/edit
  def edit url_options = {}
    @current_url = polymorphic_url [ :admin, @node.content ], url_options.merge(action: :edit)

    render action: :edit, layout: false
  end

  # Used for approving content of a given node
  #
  # GET /admin/nodes/1/audit_edit
  def audit_edit
    edit for_approval: true
  end

  # Request the number of children. Returned as a plain text string.
  #
  # XHR GET /admin/nodes/1/count_children
  def count_children
    render :text => @node.children.count
  end

  # Sort a node's children by title or creation_date, ascending or descending.
  # Note that this a SQL-heavy operation (many queries), might need to find
  # another way to implement this.
  #
  # PUT /admin/nodes/1/sort_children?sort_by=title&order=desc
  #
  # *params*
  # sort_by - Either 'date' or 'title'
  # order - Either 'desc' or 'asc'
  def sort_children
    options = {}

    case params[:sort_by]
      when 'title'
        options[:sort_by] = :content_title
      when 'date'
        options[:sort_by] = :created_at
    end

    options[:order] = params[:order] || 'asc'

    @node.sort_children(options)

    render :text => 'Sorteren gelukt.'
  end

  def set_visibility
    respond_to do |format|
      if @node.set_visibility!(!params[:hidden].to_boolean)
        format.xml  { head :ok }
        format.json { render :json => { :success => 'true' } }
      else
        format.xml  { render :xml => @node.errors.to_xml, :status => :unprocessable_entity }
        format.json { render json: { errors: @node.errors.full_messages.join(' ') }.to_json, status: :unprocessable_entity }
      end
    end
  end

  def set_accessibility
    respond_to do |format|
      if @node.set_accessibility!(!params[:private].to_boolean)
        format.xml  { head :ok }
        format.json { render :json => { :success => 'true' } }
      else
        format.xml  { render :xml => @node.errors.to_xml, :status => :unprocessable_entity }
        format.json { render json: { errors: @node.errors.full_messages.join(' ') }.to_json, status: :unprocessable_entity }
      end
    end
  end

protected

  def find_node
    @node = Node.find(params[:id]) if params[:id].present?
  end

  def find_nodes
    @nodes = Node.find(params[:ids])
  end

private

  def permitted_attributes
    params.fetch(:node).except!(:id, :hits, :content_type, :sub_content_type, :url_alias, :custom_url_alias, :hidden, :private, :publishable, :deleted_at, {}).permit!
  end

  def verify_xhr
    render(:text => '400 Bad Request', :status => 400) unless request.xhr?
  end
end
