namespace :devcms do
  namespace :newsletters do
    desc 'Send newsletter editions'
    task(:send => :environment) do
      NewsletterEditionMailerWorker.new.send_newsletter_editions
    end
  end
end
