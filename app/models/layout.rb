class Layout

  attr_accessor :id, :config, :custom_representations, :path, :name

  def initialize(id, config)
    self.id                     = id
    self.path                   = config.delete("path")
    self.name                   = config.delete("name")
    self.custom_representations = config.delete('custom_representations')
    self.config                 = config
  end

  def variants
    self.config.map do |variant, config|
      [config["name"], variant] unless ['extends', "target_defaults"].include?(variant) || !config
    end.compact
  end

  def find_variant(id)
    var = self.config[id]
    if var
      var[:id] = id
      # Set column defaults
      self.config["target_defaults"].each do |col, conf|
        if var.has_key?(col)
          var[col] = conf.dup.merge(var[col]||{})
        end
      end
    end
    var
  end

  def targets_for_variant(variant)
    variant.select { |key,val| ![:id, "name", 'inheritable'].include?(key) }  
  end

  def settings_partial
    partial_path = File.join(self.path, 'settings.html.haml')
    if File.exists?(partial_path)
      return partial_path
    elsif self.parent.present?
      return self.parent.settings_partial
    end
  end

  def targets_partial(variant)
    variant_name = variant[:id] != "default" ? variant[:id] : ''
    partial_path = File.join(self.path, variant_name, 'targets.html.haml')
    if File.exists?(partial_path)
      return partial_path
    elsif self.parent.present?
      return self.parent.targets_partial(variant)
    end
  end

  def parent
    @parent ||= Layout.find(self.config["extends"])
  end

  def self.find(id)
    self.all.find{ |layout| layout.id == id }
  end

  def self.all
    if @all_layouts.blank?
      configs = {}
      Dir[File.join(Rails.root, 'app', 'layouts', '*'), File.join(DevCMS.core_root, 'app', 'layouts', '*')].each do |layout_path|
        configs[layout_path.split('/').last] = YAML.load_file( File.join(layout_path, 'config.yml')).merge({'path' => layout_path})
      end
      @all_layouts = configs.map do |id, config|
        if parent = config['extends']
          config = configs[parent].merge(config)
        end
        self.new(id, config.dup)
      end
    end
    return @all_layouts
  end
end
