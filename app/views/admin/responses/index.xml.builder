xml.results do
  xml.tag!('total_count', @responses.count)
  xml.responses do
    @responses.each do |response|
      xml.response do
        xml.id(response.id)
        xml.ip(response.ip)
        xml.email(response.email)        
        xml.created_at(response.created_at.strftime("%d-%m-%Y %H:%M"))
        xml.fields {
          response.response_fields.includes(:contact_form_field).order('contact_form_fields.position asc').each do |response_field|
            if response_field.file?
              download_url = file_admin_contact_form_response_response_field_url(response.contact_form, response, response_field)
              xml.tag!("field_#{response_field.contact_form_field.id}", link_to(response_field.value, download_url), :label => response_field.contact_form_field.label)
            else
              xml.tag!("field_#{response_field.contact_form_field.id}", html_escape(response_field.value), :label => response_field.contact_form_field.label)
            end
          end
        }
      end
    end
  end
end


