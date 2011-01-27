module Admin::AdminHelper

  # Returns the HTML for the main menu for the admin interface.
  def create_admin_menu
    sitemap = {
      :page => :sitemap,
      :url  => { :controller => 'admin/nodes', :action => :index },
      :text => I18n.t('admin.sitemap')
    }
    users = {
      :page => :users,
      :url  => { :controller => 'admin/users', :action => :index },
      :text => I18n.t('admin.users_button')
    }
    permissions = {
      :page => :permissions,
      :url  => { :controller => 'admin/permissions', :action => :index },
      :text => I18n.t('admin.rights')
    }
    approvals = {
      :page => :approvals,
      :url  => { :controller => 'admin/approvals', :action => :index },
      :text => I18n.t('admin.approvals_button')
    }
    comments = {
      :page => :comments,
      :url  => { :controller => 'admin/comments', :action => :index },
      :text => I18n.t('admin.comments_button')
    }
    categories = {
      :page => :categories,
      :url  => { :controller => 'admin/categories', :action => :index },
      :text => I18n.t('admin.categories_button')
    }
    settings = {
      :page => :settings,
      :url  => { :controller => 'admin/settings', :action => :index },
      :text => I18n.t('admin.settings_button')
    }    

    menu_items = [sitemap]
    menu_items.concat [users, permissions, categories, settings] if current_user.has_role?('admin')

    if current_user.has_role?('admin', 'final_editor')
      menu_items << comments
      menu_items.unshift approvals
    end

    menu_anchors = []
    menu_items.each do |item|
      if item[:page] == @active_page
        item[:options]         ||= {}
        item[:options][:class] ||= ''
        item[:options][:class] << ' active'
      end
      menu_anchors << link_to(item[:text], item[:url], item[:options]||{})
    end
    menu_anchors
  end

  def create_action_menu
    menu_anchors = []
    if @actions
      @actions.each do |item|
        unless item[:ajax] == false
          menu_anchors << link_to_remote(item[:text], :update => 'right_panel_body', :url => item[:url], :method => item[:method])
        else
          menu_anchors << link_to(item[:text], item[:url], :target => (item[:target] == :blank) ? '_blank' : '')
        end
      end
    end

    menu_anchors
  end

  def content_box_settings_for(content, show_number_of_items_field = true, show_icon_field = true)
    render :partial => 'admin/shared/content_box_fields', :locals => { :content => content, :show_number_of_items_field => show_number_of_items_field, :show_icon_field => show_icon_field }
  end

  def content_box_hidden_fields(form)
    render :partial => 'admin/shared/content_box_hidden_fields', :locals => { :form => form }
  end

  def category_settings_for(content)
    render :partial => 'admin/shared/category_fields', :locals => { :content => content }
  end

  def category_hidden_fields(form)
    render :partial => 'admin/shared/category_hidden_fields', :locals => { :form => form }
  end
  
  def time_select_for(carrousel)    
    [
      label_tag(     'carrousel[display_time][]', Carrousel.human_attribute_name(:display_time)) + ': ',
      text_field_tag('carrousel[display_time][]', carrousel.display_time[0], :size => 2),
      select_tag(    'carrousel[display_time][]', options_for_select(Carrousel::ALLOWED_TIME_UNITS.collect{|unit| [t(unit, :scope => 'carrousels.units'), unit] }, carrousel.display_time[1]))
    ].join("\n")
  end

  def commit_fields(form)
    hidden_field_tag(:commit_type) +
    form.submit(I18n.t('shared.preview'), :onclick => "$('commit_type').setValue('preview'); return true;") +
    form.submit(I18n.t('shared.save'),    :onclick => "$('commit_type').setValue('save'); return true;")
  end

  def approval_field
    hidden_field_tag(:for_approval, true) if @for_approval
  end

  def create_message
    '<div class="rightPanelDefault" id="rightPanelDefault"><table><tr><td>' + t('shared.created') + '</td></tr></table></div>'
  end

  def update_message
    '<div class="rightPanelDefault" id="rightPanelDefault"><table><tr><td>' + t('shared.updated') + '</td></tr></table></div>'
  end
end
