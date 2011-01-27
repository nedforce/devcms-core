module DateExtensions
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
end
