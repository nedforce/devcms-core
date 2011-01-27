RailsTidy.tidy_configuration = RAILS_ROOT + "/config/tidy.rc"

case PLATFORM
when 'i386-mswin32'
  RailsTidy.tidy_path = RAILS_ROOT + '/vendor/tidy/lib/mswin32/tidy.dll'
else # Linux
  RailsTidy.tidy_path = (PLATFORM =~ /64/ ? '/usr/lib64/libtidy.so' : '/usr/lib/libtidy.so') # 64 or 32-bit?
end
