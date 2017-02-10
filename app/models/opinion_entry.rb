class OpinionEntry < ActiveRecord::Base
  
  belongs_to :opinion

  validates :feeling, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 3 }
  validates :description, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 4 }

end
