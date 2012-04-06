RailsTidy.tidy_configuration = RAILS_ROOT + "/config/tidy.rc"

RailsTidy.tidy_path = case PLATFORM
when 'i386-mswin32'
  RAILS_ROOT + '/vendor/tidy/lib/mswin32/tidy.dll'
when 'x86_64-linux'
  '/usr/lib64/libtidy.so'
else # Linux 32 bit
  '/usr/lib/libtidy.so'
end
