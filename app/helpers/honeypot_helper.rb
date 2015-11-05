module HoneypotHelper
  def render_honeypot
    (text_field_tag(Rails.application.config.honeypot_empty_name, '', title: 'Leeg laten', class: Rails.application.config.honeypot_class) + text_field_tag(Rails.application.config.honeypot_name, Rails.application.config.honeypot_value, title: 'Niet wijzigen', class: Rails.application.config.honeypot_class)).html_safe
  end
end
