module CalendarsHelper

  def determine_classes(calendar, date, user, is_other_month, is_selected = false)
    classes = []
    classes << 'today' if date == Date.today

    if is_other_month
      classes << 'isSelected' if is_selected
      classes << 'otherMonthDay'
    else
      classes << 'day'
      classes << 'isSelected' if is_selected
      classes << 'hasCalendarItems' if @calendar_items[date.mday].present?
    end

    classes
  end
end
