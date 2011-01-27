SHARE_POINT_CONFIG = {}
SHARE_POINT_CONFIG[:prefix] = "prefix"
SHARE_POINT_CONFIG[:row_limit] = 5 # 5 works, 50 seems to be to much..
SHARE_POINT_CONFIG[:test_list_guid] = "6EB07052-9EDC-4B97-8118-7EF2CA3F4598"
SHARE_POINT_CONFIG[:log_level] = Logger::DEBUG if RAILS_ENV == 'development'

SHARE_POINT_CONFIG[:sites] = {
  '123456-9EB7-48E2-8B99-61CA8C99A294' => {
    :creates => 'CalendarItem',
    :mapping => {
      :title => 'ows_Title'
    }    
  },
  :default => {
    :creates => 'Attachment',
    :mapping => {
      :title => 'ows_LinkFilename',      
      :file_ref => 'ows_FileRef'
    }
  }
}

SHARE_POINT_CONFIG[:black_and_white_list] = {
  "dir1" => {
    'dir2' => {
      'dir3' => {
        'descend_into_dir4' => true,
        'descend_into_dir5' => false
      },
      'dir6' => false
    },
  "dir7" => true,
  "dir8"      => true,
  "dir9" => true}
}