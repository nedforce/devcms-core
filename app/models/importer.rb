class ImporterException < RuntimeError
end

class Importer
  
  TYPE_COLUMN_NAME = 'Type'
  TARGET_SECTION_COLUMN_NAME = 'Sectie'
  SHOW_IN_MENU_COLUMN_NAME = 'InMenuTonen'

  DEFAULT_TYPE = 'Pagina'
  DEFAULT_SHOW_IN_MENU = true

  DEFAULT_NODE_ATTRIBUTES = {}

  IMPORTABLE_CONTENT_TYPES = {
    'Pagina' => {
      :type => 'Page',
      'Titel' => 'title',
      'Samenvatting' => 'preamble',
      'Tekst' => 'body'
    }
  }
  
  def self.import!(file, current_section)
    @current_section = current_section
    
    file_path = file.path
    
    unless File.extname(file_path) == ".xlsx"
      File.rename(file_path, "#{file_path}.xlsx")
      file_path += ".xlsx"
    end
    
    @spreadsheet = Excelx.new(file_path)
    @spreadsheet.default_sheet = @spreadsheet.sheets.first
    
    header_row = @spreadsheet.first_row
    @first_row = header_row + 1
    @last_row = @spreadsheet.last_row
    
    @header = @spreadsheet.row(header_row)
    
    @type_column = @header.index(TYPE_COLUMN_NAME)
    @target_section_column = @header.index(TARGET_SECTION_COLUMN_NAME)
    @show_in_menu_column = @header.index(SHOW_IN_MENU_COLUMN_NAME)
    
    @special_columns = [ @type_column, @target_section_column, @show_in_menu_column ].compact
    
    ActiveRecord::Base.transaction do
      parse!
    end
  rescue Exception => e
    puts e.message
    false
  end
  
protected

  def self.parse!
    instances = []
    
    @first_row.upto(@last_row) do |row|
      @current_row = row
      instances << self.parse_row(@spreadsheet.row(row))
    end
    
    instances
  end

  def self.parse_row(row_contents)
    meta_attributes = parse_meta_attributes(row_contents)
    mapping = IMPORTABLE_CONTENT_TYPES[meta_attributes[:type]]
    
    raise ImporterException.new("Error while importing: unknown type '#{meta_attributes[:type]}' in row #{@current_row}") unless mapping
    
    klass = mapping[:type].constantize
    parent = find_or_create_target_section(meta_attributes[:target_section]).node
    
    attributes = parse_attributes(row_contents, mapping)

    create_content!(klass, attributes, parent, DEFAULT_NODE_ATTRIBUTES.merge(:show_in_menu => meta_attributes[:show_in_menu]))
  end
  
  def self.parse_meta_attributes(row_contents)
    {
      :type => determine_meta_attribute_value(row_contents, @type_column, DEFAULT_TYPE),
      :target_section => determine_meta_attribute_value(row_contents, @target_section_column, nil),
      :show_in_menu => determine_meta_attribute_value(row_contents, @show_in_menu_column, DEFAULT_SHOW_IN_MENU)
    }
  end
  
  def self.determine_meta_attribute_value(row_contents, meta_attribute_index, default)
    meta_attribute_index && row_contents[meta_attribute_index] ? row_contents[meta_attribute_index] : default
  end
  
  def self.find_or_create_target_section(section_alias)
    return @current_section if section_alias.blank?
    
    target_section = @current_section

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
    raise ImporterException.new("Error while importing: could not create target section for the alias '#{section_alias}' in row #{@current_row}")
  end
  
  def self.parse_attributes(row_contents, mapping)
    attributes = {}
    
    row_contents.each_with_index do |cell_contents, column|
      next if @special_columns.include?(column)
      
      attribute_alias = @header[column]
      
      raise ImporterException.new("Error while importing: invalid attribute in cell (#{@current_row}, #{column + 1})") unless attribute_alias
      
      attribute_name = mapping[attribute_alias]
      
      raise ImporterException.new("Error while importing: unknown attribute '#{attribute_alias}' in row #{@current_row}") unless attribute_alias
      
      attributes[attribute_name] = cell_contents
    end
    
    attributes
  end
  
  def self.create_content!(klass, attributes, parent, node_attributes)
    instance = klass.new(attributes.merge(:parent => parent))
    instance.node.attributes = node_attributes
    instance.save!
    instance
  rescue ActiveRecord::RecordNotSaved
    raise ImporterException.new("Error while importing: could not create new #{klass} instance for the attributes in row #{@current_row}")
  end
  
end