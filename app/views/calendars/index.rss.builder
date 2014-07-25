xml << render(:partial => 'shared/feed', :locals => { :items => @calendar_items, :title => @feed_title || I18n.t('calendars.all_calendar_items'), :url => calendars_url(:format => 'rss') })
