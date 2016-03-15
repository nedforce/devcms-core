namespace :db do
  desc 'Remove unverified users'
  task(remove_unverified_users: :environment) do
    conditions = ['created_at < ? and verified = ?', 7.days.ago, false]

    User.where(conditions).each do |user|
      puts user.inspect
    end

    User.where(conditions).destroy_all
  end
end
