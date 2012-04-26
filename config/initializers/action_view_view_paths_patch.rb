# Patch: ensure engine view paths are always available, even in mailers.
# Remove after Rails 3 upgrade
class ActionView::Base
  def view_paths
    @extended_view_paths ||= ActionView::PathSet.new(@view_paths + ActionController::Base.view_paths).uniq
  end
end