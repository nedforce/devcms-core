module ContactBoxesHelper
  def text_for_today(contact_box)
    today = Date.today

    daily_text = case today.cwday
    when 1
      contact_box.monday_text
    when 2
      contact_box.tuesday_text
    when 3
      contact_box.wednesday_text
    when 4
      contact_box.thursday_text
    when 5
      contact_box.friday_text
    when 6
      contact_box.saturday_text
    when 7
      contact_box.sunday_text
    end

    daily_text.present? ? daily_text : contact_box.default_text
  end
end
