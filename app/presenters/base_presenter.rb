class BasePresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def h
    @template
  end
end
