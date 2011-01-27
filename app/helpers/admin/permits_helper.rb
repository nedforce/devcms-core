module Admin::PermitsHelper
  def unique_spatial_index(spatial)
    return unless spatial.new_record?

    @spatial_counter ||= 0
    @spatial_counter  += 1
    { :index => Time.now.to_s + @spatial_counter.to_s }
  end
end
