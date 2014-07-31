class Date
  def start_of_week
    self - (self.cwday - 1)
  end

  def end_of_week
    self + (7 - self.cwday)
  end

  def start_of_month
    Date.civil(self.year, self.month, 1)
  end

  def end_of_month
    Date.civil(self.year, self.month, -1)
  end

  def valid_gregorian_date?
    return false if self.nil?
    (self.month == 2 and self.day == 29) ? Date.gregorian_leap?(self.year) : true
  end
end
