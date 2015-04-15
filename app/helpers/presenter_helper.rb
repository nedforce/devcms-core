module PresenterHelper
  # presents object, tries to find a presenter with object.class as name,
  # or, if object is an activerecord and uses sti, one of it's parent classes
  # upto Activerecord::Base. Yields to block with presenter as argument
  # if block is given otherwise just returns the presenter
  #
  #   args: passed to presenter after object and self
  #
  def present object, *args, &block
    present_with_class object, presenter_class_for(object.class), *args, &block
  end

  # same as present, but with the presenter class specified
  def present_with_class object, presenter_class, *args, &block
    presenter_args = [object, self] + args
    presenter = presenter_class.new(*presenter_args)

    yield presenter if block
    presenter
  end

  def presenter_class_for object_class
    begin
      "#{object_class}Presenter".constantize
    rescue
      if object_class < ActiveRecord::Base
        object_class.ancestors.select { |a| a.respond_to?(:model_name)}.inject(nil) { |memo, a| memo || ("#{a}Presenter".constantize rescue nil) } || BasePresenter
      else
        BasePresenter
      end
    end
  end
end
