module Admin::DiffHelper
  def diff(page1, page2)
    HTMLDiff.diff(page1, page2)
  end
end
