class Array
  
  # Tests for set equality for two arrays, i.e., order-independent equality.
  # Two arrays are equal if they contain the same elements, but not necessarily in the same order.
  def set_equals?(other_array)
    return false unless other_array.is_a?(Array)
    (self - other_array).empty? && (other_array - self).empty?
  end
  
end
