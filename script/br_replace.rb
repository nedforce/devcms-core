CONTENT_TYPES_TO_FIX = {
  'Page' => [ :body ],
  'Section' => [ :description ],
  'NewsItem' => [ :body ],
  'AgendaItem' => [ :body ],
  'CalendarItem' => [ :body ],
  'NewsArchive' => [ :description ],
  'NewsletterArchive' => [ :description ],
  'ProductCatalogue' => [ :description ],
  'WeblogPost' => [ :body, :preamble ],
  'Weblog' => [ :description ]
}

P_TAG_REGEXP = %r(<\s*p\s*>)
BR_TAG_REGEXP = %r(<\s*br\s*(\/)?\s*>)

BR_TAG_VARIATIONS = [ '<br>', '<br/>', '<br >', '<br />' ]

CONTENT_TYPES_TO_FIX.each do |content_class_name, attributes|
  puts "Running BR-fix for content type '#{content_class}'..."

  attributes.each do |attr|
    condition_strings = []
    condition_args = []
    
    BR_TAG_VARIATIONS.each do |variation|
      condition_strings << "#{content_class.table_name}.#{attr} LIKE ?"
      condition_args << "%#{variation}%"
    end
    
    conditions = [ condition_strings.join(' OR '), condition_args ].flatten
    
    ActiveRecord::Base.transaction do
      instances_to_fix = class_exists?(content_class_name) ? content_class.constantize.find(:all, :conditions => conditions) : []
      
      puts "Found #{instances_to_fix.size} instances to fix..."
      
      instances_to_fix.each do |instance|
        value = instance.send(attr)
        p instance.id
        
        # Field contains a p, so we replace the br tag by a pair of p tags
        if value =~ P_TAG_REGEXP
          instance.update_attributes!(attr => value.gsub(BR_TAG_REGEXP, '</p><p>'))
        # Field contains no p
        else
          instance.update_attributes!(attr => value.gsub(BR_TAG_REGEXP, ''))
        end
      end
    end
  end
end

