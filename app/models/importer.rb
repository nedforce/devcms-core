class ImporterException < RuntimeError
end

class Importer

  def self.import!(file, target_section, save_new_content = true)
    self.new(file, target_section, save_new_content).tap do |importer|
      importer.import!
    end
  end
  
  def initialize(file, target_section, save_new_content)
    @target_section   = target_section
    @save_new_content = save_new_content

    if file.present?
      @file_path = file.is_a?(String) ? file : file.path

      # Filename needs to end in '.xlsx', otherwise roo will not recognize it as an Excel spreadsheet ...
      if File.extname(@file_path) != '.xlsx'
        File.rename(@file_path, "#{@file_path}.xlsx")
        @file_path += '.xlsx'
      end
    end
  end

  def import!
    @instances = []
    @errors    = []

    if @file_path.present?
      begin
        @spreadsheet = Excelx.new(@file_path)
        @spreadsheet.default_sheet = @spreadsheet.sheets.first

        ActiveRecord::Base.transaction do
          self.parse_spreadsheet
        end
      rescue => e
        @errors << e.message
      end
    else
      @errors << 'geen bestand opgegeven'
    end
  end

  def success?
    @errors.empty?
  end

  def instances
    @instances
  end

  def errors
    @errors
  end

protected

  def self.default_attribute_information
    {
      :required => true,
      :default  => nil
    }
  end

  def self.meta_attributes
    {
      'Type'   => { :mapping => :type,           :required => false, :default => 'Pagina' },
      'Sectie' => { :mapping => :target_section, :required => false }
    }
  end

  def self.node_attributes
    {
     'InMenuTonen' => { :mapping => :show_in_menu, :required => false, :default => true }
    }
  end

  def self.importable_content_types
    {
      'Pagina' => {
        :type          => 'Page',
        'Titel'        => 'title',
        'Samenvatting' => 'preamble',
        'Tekst'        => 'body'
      }
    }
  end

  def parse_spreadsheet
    header_row = @spreadsheet.first_row
    
    @header = @spreadsheet.row(header_row)
    @column_mapping = {}
    
    (header_row + 1).upto(@spreadsheet.last_row) do |row|
      @current_row = row
      self.parse_row
    end
  end

  def parse_row
    @row_contents = @spreadsheet.row(@current_row)
    
    meta_attributes = self.parse_meta_attributes
    mapping = self.class.importable_content_types[meta_attributes[:type]]
    
    raise ImporterException.new("onbekend type '#{meta_attributes[:type]}' in rij #{@current_row}") unless mapping
    
    klass = mapping.delete(:type).constantize
    parent = self.find_or_create_target_section(meta_attributes[:target_section]).node
    
    node_attributes = self.parse_node_attributes
    content_attributes = self.parse_content_attributes(mapping)
    
    self.create_content!(klass, parent, content_attributes, node_attributes)
  end
  
  def find_or_create_target_section(section_alias)
    return @target_section if section_alias.blank?
    
    target_section = @target_section

    section_alias.split('\\').each do |title|
      title.strip!
      
      section_node = target_section.node.children.sections.find_by_title(title)
      
      target_section = if section_node
         section_node.content
      else
        Section.create!(:title => title, :parent => target_section.node)
      end
    end
    
    target_section
  rescue ActiveRecord::RecordNotSaved
    raise ImporterException.new("kon geen sectie aanmaken voor het gegeven alias '#{section_alias}' in rij #{@current_row}")
  end
  
  def parse_meta_attributes
    self.parse_attributes(self.class.meta_attributes)
  end
  
  def parse_node_attributes
    self.parse_attributes(self.class.node_attributes)
  end
  
  def parse_content_attributes(mapping)
    self.parse_attributes(mapping)
  end
  
  def parse_attributes(mapping)
    attributes = {}
    
    mapping.each do |column_name, attribute_information_string_or_hash|
      column = self.column_for(column_name)
      attribute_information = self.parse_attribute_information(attribute_information_string_or_hash)
      
      if column
        attribute_value = @row_contents[column]
                
        if attribute_value.blank? && attribute_information[:required]
          raise ImporterException.new("vereiste attribuut '#{column_name}' ontbreekt in rij #{@current_row}")
        else
          attributes[attribute_information[:mapping]] = attribute_value.blank? ? attribute_information[:default] : attribute_value
        end
      elsif attribute_information[:required]
        raise ImporterException.new("vereiste kolom '#{column_name}' ontbreekt")
      else
        attributes[attribute_information[:mapping]] = attribute_information[:default]
      end
    end
    
    attributes
  end
  
  def create_content!(klass, parent, content_attributes, node_attributes)
    instance = klass.new(content_attributes.merge(:parent => parent))
    instance.node.attributes = node_attributes
    
    instance.save if @save_new_content
    
    @instances << instance

    if !instance.valid?
      raise ImporterException.new("kon geen #{klass} instantie aanmaken voor de attributen in rij #{@current_row}")
    end
  end
  
  def column_for(column_name)
    @column_mapping[column_name] ||= @header.index(column_name)
  end
  
  def parse_attribute_information(attribute_information)
    self.class.default_attribute_information.merge(attribute_information.is_a?(String) ? { :mapping => attribute_information } : attribute_information)
  end  
end
