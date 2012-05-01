# config/initializers/time_formats.rb

# W3CDTF format: YYYY-MM-DD / YYYY-MM-DDThh:mm:ss.sTZD
Time::DATE_FORMATS[:w3cdtf] = lambda { |time| time.strftime("%Y-%m-%dT%H:%M:%S.000#{time.formatted_offset}") }
#Time::DATE_FORMATS[:w3cdtf] = "%Y-%m-%d"
Time::DATE_FORMATS[:w3cdtfutc] = lambda { |time| time.strftime("%Y-%m-%dT%H:%M:%S.000Z") }

Date::DATE_FORMATS[:long] = lambda { |date| date.strftime("%e %B %Y") }