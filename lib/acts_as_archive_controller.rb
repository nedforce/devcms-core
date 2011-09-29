module Acts #:nodoc:
  module ArchiveController #:nodoc:

    def self.included(base)
      base.extend(Archived)
    end

    module ClassMethods
      attr_accessor :content_class_name, :singular_name, :date_attribute, :render_weeks     
    end

    module InstanceMethods
      def show
        respond_to do |format|
          format.html { render :partial => 'show', :layout => 'admin/admin_show' }
          format.xml  { render :xml => record }
        end
      end

      def index
        respond_to do |format|
          node_id     = params[:super_node] || params[:node]
          record_node = Node.find(node_id)          
          instance_variable_set("@#{self.class.singular_name}_node", record_node)

          active_node = params[:active_node_id] ? Node.find(params[:active_node_id]) : nil
          archive_includes_active_node = active_node && record_node.children.include?(active_node)

          format.json do
            # TODO: Refactor line below. This works as well?
            #if !self.class.render_weeks && @year && @month
            if !self.class.render_weeks == true && @year && @month
              record_nodes = record_node.content.find_all_items_for_month(@year, @month).map { |c| c.node }
              render :json => record_nodes.map { |node| node.to_tree_node_for(current_user) }.to_json
            elsif self.class.render_weeks == true && @year && (@week = params[:week])
              record_nodes = record_node.content.find_all_items_for_week(@year, @week.to_i).map { |c| c.node }
              render :json => record_nodes.map { |node| node.to_tree_node_for(current_user) }.to_json
            else
              role        = current_user.role_on(record_node)
              common_hash = { :treeLoaderName => Node.content_type_configuration(self.class.content_class_name)[:tree_loader_name], :userRole => role ? role.name : "" }

              if @year
                self.class.render_weeks == true ? render_weeks(record_node, node_id, common_hash, active_node, archive_includes_active_node) : render_months(record_node, node_id, common_hash, active_node, archive_includes_active_node)
              else
                render_years(record_node, node_id, common_hash, active_node, archive_includes_active_node)
              end
            end
          end
        end
      end

      protected

        def record
          instance_variable_get("@#{self.class.singular_name}")
        end

        def find_record
          instance_variable_set("@#{self.class.singular_name}", self.class.content_class_name.constantize.find(params[:id], :include => [:node]).current_version)
        end

        def render_weeks(record_node, node_id, common_hash, active_node, archive_includes_active_node)
          now = Date.today

          @weeks = record_node.content.find_weeks_with_items_for_year(@year).map do |w|
            active_node_date = active_node.content.send(self.class.date_attribute) if archive_includes_active_node
            week_includes_active_node = archive_includes_active_node && (active_node_date.year == @year && active_node_date.cweek == w)
            {
              :text        => I18n.t('shared.week', :week => w).capitalize,
              :expanded    => week_includes_active_node || (!archive_includes_active_node && (@year == now.year && w == now.cweek)),
              :extraParams => {
                :super_node => node_id,
                :year       => @year,
                :week       => w
              }
            }.reverse_merge(common_hash)
          end

          render :json => @weeks
        end

        def render_months(record_node, node_id, common_hash, active_node, archive_includes_active_node)
          now = Time.now

          @months = record_node.content.find_months_with_items_for_year(@year).map do |m|
            active_node_date = active_node.content.send(self.class.date_attribute) if archive_includes_active_node
            month_includes_active_node = archive_includes_active_node && (active_node_date.year == @year && active_node_date.month == m)
            {
              :text        => I18n.l(Date.new(2000, m), :format => "%B").capitalize,
              :expanded    => month_includes_active_node || (!archive_includes_active_node && (@year == now.year && m == now.month)),
              :extraParams => {
                :super_node => node_id,
                :year       => @year,
                :month      => m
              }
            }.reverse_merge(common_hash)
          end

          render :json => @months.to_json
        end

        def render_years(record_node, node_id, common_hash, active_node, archive_includes_active_node)
          now = Time.now

          @years = (self.class.render_weeks == true ? record_node.content.find_commercial_years_with_items : record_node.content.find_years_with_items).map do |y|
            year_includes_active_node = archive_includes_active_node ? (active_node.content.send(self.class.date_attribute).year == y) : false
            {
              :text        => y,
              :expanded    => year_includes_active_node || (!archive_includes_active_node && (y == now.year)),
              :extraParams => {
                :super_node => node_id,
                :year       => y
              }
            }.reverse_merge(common_hash)
          end

          render :json => @years.to_json
        end
    end

    module CreateMethods
      def new
        instance_variable_set("@#{self.class.singular_name}", self.class.content_class_name.constantize.new(params[self.class.singular_name.to_sym]))

        respond_to do |format|
          format.html { render :template => 'admin/shared/new', :locals => { :record => record }}
        end
      end

      def create
        record = self.class.content_class_name.constantize.new(params[self.class.singular_name.to_sym])

        instance_variable_set("@#{self.class.singular_name}", record)        
        record.parent = @parent_node

        respond_to do |format|
          if @commit_type == 'preview' && record.valid?
            format.html { render :template => 'admin/shared/create_preview', :locals => { :record => record }, :layout => 'admin/admin_preview' }
            format.xml  { render :xml => record, :status => :created, :location => record }
          elsif @commit_type == 'save' && record.save
            format.html { render :template => 'admin/shared/create' }
            format.xml  { render :xml => record, :status => :created, :location => record }
          else
            format.html { render :template => 'admin/shared/new', :locals => { :record => record }, :status => :unprocessable_entity }
            format.xml  { render :xml => record.errors, :status => :unprocessable_entity }
          end
        end
      end
    end

    module UpdateMethods
      def edit
        record.attributes = params[self.class.singular_name.to_sym]

        respond_to do |format|
          format.html { render :template => 'admin/shared/edit', :locals => { :record => record }}
        end
      end

      def update
        record.attributes = params[self.class.singular_name.to_sym]

        respond_to do |format|
          if @commit_type == 'preview' && record.valid?
            format.html { render :template => 'admin/shared/update_preview', :locals => { :record => record }, :layout => 'admin/admin_preview' }
            format.xml  { render :xml => record, :status => :created, :location => record }
          elsif @commit_type == 'save' && record.save
            format.html { render :template => 'admin/shared/update' }
            format.xml  { head :ok }
          else
            format.html { render :template => 'admin/shared/edit', :locals => { :record => record }, :status => :unprocessable_entity }
            format.xml  { render :xml => record.errors, :status => :unprocessable_entity }
          end
        end
      end
    end

    module Archived
      # Mixes-in the behaviour for a controller surrounding a archive resource specified with ActsAsArchive
      # By default only adds read actions (show, index)
      #
      # *Parameters*
      # * +model_name+ singular model name as string or symbol
      #
      # *Options*
      # * +allow_create+ Add create and new actions
      # * +allow_update+ Add update and edit actions
      def acts_as_archive_controller(model_name, options = {})
        extend ClassMethods

        prepend_before_filter :find_parent_node, :only => [ :new, :create ]
        before_filter :find_record,              :only => [ :show, :edit, :update ]
        before_filter :set_commit_type,          :only => [ :create, :update ]
        before_filter :parse_date_parameters,    :only => [ :index ]
        layout false

        self.singular_name      = model_name.to_s
        self.content_class_name = singular_name.camelize
        self.date_attribute     = options[:date_attribute] || :created_at
        self.render_weeks       = options[:render_weeks]   || false

        include InstanceMethods
        include CreateMethods unless options[:allow_create] == false
        include UpdateMethods unless options[:allow_update] == false
      end
    end
  end
end
