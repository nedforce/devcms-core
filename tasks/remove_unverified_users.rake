namespace :db do
  desc 'Remove unverified users'
  task(:remove_unverified_users => :environment) do
    conditions = ['created_at < ? and verified = ?', 7.days.ago, false]
    User.all(:conditions => conditions).each do |user|
      puts user.inspect
    end
    User.destroy_all(conditions)
  end
end