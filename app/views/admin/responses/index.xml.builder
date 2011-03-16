xml.results do
  xml.tag!('total_count', @responses.count)
  xml.responses do
    @responses.each do |response|
      xml.response do
        xml.id(response.id)
        xml.ip(response.ip)
        xml.created_at(response.created_at.strftime("%d-%m-%Y %H:%M"))
        xml.fields {
          response.response_fields.each do |response_field|
              xml.tag!("field_#{response_field.contact_form_field.id}", response_field.value, :label => response_field.contact_form_field.label)
          end
        }
      end
    end
  end
end


