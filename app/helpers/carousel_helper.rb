module CarouselHelper
  def carousel_data content_node
    data = case content_node.animation 
    when Carrousel::ANIMATION_FADE_IN
      { :effect => 'fade' }
    when Carrousel::ANIMATION_SPRING
      { :effect => 'slide-horizontal', :easing => 'easeOutElastic', :circular => true }
    when Carrousel::ANIMATION_SLIDE
      { :effect => 'slide-horizontal', :easing => 'linear', :circular => true }
    else
      { :effect => 'slide-horizontal', :easing => 'swing', :circular => true }
    end

    delay = content_node.display_time ? content_node.display_time * 1000 : nil
    speed = content_node.transition_time_in_seconds ? content_node.transition_time_in_seconds * 1000 : nil
    speed = 0 if content_node.animation == Carrousel::ANIMATION_NONE

    data.merge!({ :id => content_node.id, :toggle => 'carousel', :delay => delay, :speed => speed })
  end
end
