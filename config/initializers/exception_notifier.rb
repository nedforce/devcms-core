Rails.application.config.middleware.use ExceptionNotifier,
  :email_prefix => "[#{Rails.application.class.to_s.split('::').first } | #{Rails.env}] ",
  :sender_address => %{"Exception Notifier" <exceptions@nedforce.nl>},
  :exception_recipients => %w{exceptions@nedforce.nl}