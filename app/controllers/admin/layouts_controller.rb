class Admin::LayoutsController < Admin::AdminController
  before_filter :find_node, only: [:edit, :variants_settings_and_targets, :targets, :update]
  before_filter :find_layout
  before_filter :find_current_sortlets, only: [:edit, :targets, :variants_settings_and_targets]

  layout false

  def edit
  end

  def update
    # Parameters: { "node" => { "layout" => "deventer", "layout_variant" => "default", "template_color" => "default" },
    #               "targets" => { "primary_column" => ["1"], "main_content_column" => ["4","5"], "secondary_column" => [nil] } }
    if params['node'].present?
      set_footer_links
      success = @node.update_layout(node: params['node'], targets: params['targets']) rescue false

      if success
        render text: 'ok', status: :ok
      else
        render text: 'not ok', status: :precondition_failed
      end
    elsif @node.reset_layout
      render text: 'ok', status: :ok
    end
  end

  def variants_settings_and_targets
    if @layout.present?
      render partial: 'variants_settings_and_targets'
    else
      render nothing: true
    end
  end

  def targets
    render partial: 'targets'
  end

  protected

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_layout
    @layout = Layout.find(params[:id]) || @node.own_or_inherited_layout

    if @layout.present?
      @variant = @layout.find_variant(params[:variant_id]) || @node.own_or_inherited_layout_variant
    end
  end

  def find_current_sortlets
    return if @layout.blank? || @variant.blank?

    @current_sortlets = {}
    # Setup the custom representations
    @current_sortlets[:custom_representations] = @node.own_or_inherited_layout.custom_representations.map do |type, config|
      {
        title:                 I18n.t("#{@node.content_type.tableize}.#{type}", default: config['name']),
        representation:        config['representation'],
        custom_representation: true,
        nodeId:                type,
        hideClose:             true,
        xtype:                 'sortlet'
      }
    end

    @layout.targets_for_variant(@variant).each do |target, config|
      @current_sortlets[target] = @node.content_representations.select { |cbe| cbe.target == target }.map do |el|
        if el.custom_type.present?
          ct = @current_sortlets[:custom_representations].select { |ct| ct[:nodeId] == el.custom_type }.first
          @current_sortlets[:custom_representations].delete(ct)
          { id: el.id }.merge(ct)
        else
          {
            title:  el.content.content.content_title,
            id:     el.id,
            node:   el.content.to_tree_node_for(current_user),
            nodeId: el.content.id,
            xtype:  'sortlet'
          }
        end
      end

      if config['main_content'] == true && @node.content_type == 'Section' && @node.content.frontpage_node.present?
        front_page_node = @node.content.frontpage_node
        @current_sortlets[target] = [{ title: front_page_node.content.content_title, id: front_page_node.id, nodeId: front_page_node.id, data: { node: front_page_node.to_tree_node_for(current_user) }, xtype: 'sortlet' }]
      end
    end
  end

  def set_footer_links
    if params[:node]
      footer_links = params[:node][:layout_configuration][:footer_links]
      if footer_links
        params[:node][:layout_configuration][:footer_links] = footer_links.select { |_index, link| link[:text].present? && link[:url].present? }
      end
    end
  end
end
