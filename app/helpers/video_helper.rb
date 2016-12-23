module VideoHelper
  # Return HTML to embed a YouTube video based on a given +youtube_id+.
  def youtube_object_for_id(youtube_id)  
    case Settler[:display_videos_as_images]
    when true
      return link_to(image_tag("https://img.youtube.com/vi/#{youtube_id}/0.jpg", :alt => t('shared.youtube_video'), :title => t('shared.youtube_video')), "https://www.youtube.com/watch?v=#{youtube_id}")
    else
      return <<-HTML
        <div class="videoObject">
          <object width="425" height="355">
            <param name="movie" value="https://www.youtube.com/v/#{youtube_id}"/>
            <param name="wmode" value="transparent"/>
            <embed src="https://www.youtube.com/v/#{youtube_id}" type="application/x-shockwave-flash" wmode="transparent" width="425" height="355"></embed>
          </object>
        </div>
      HTML
    end
  end

  def process_video_tags(str)
    white_list(replace_video_tags_with(str.to_s, youtube_object_for_id('\1'.strip)))
  end

  def strip_video_tags(str)
    replace_video_tags_with(str.to_s, '')
  end

  def replace_video_tags_with(str, substr)
    str.to_s.gsub(/\[\[youtube:([[:alnum:]_-]+)\]\]/, substr)
  end
end
