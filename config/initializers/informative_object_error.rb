class ActiveRecord::RecordInvalid
  def to_s
    message = "Invalid #{record.class.name} record - "
    record.errors.each do |attribute, msg|
      attribute = attribute.to_s
      attribute_value = case 
        when (nested_atts = attribute.split('.')).size > 1          
          nested_atts[0..-2].inject([]){|m, na| (m.any? ? m.last : record).send(na.to_sym) }       
        else
          record.send(attribute) unless attribute == 'base'
        end
      message += (attribute == 'base') ? msg : "#{attribute.to_s.humanize} #{msg} ('#{attribute_value}')."
    end
    message
  end
end
