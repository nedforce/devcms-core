namespace :devcms do
  desc 'Encrypts password settings for passwords that have not been encrypted yet'
  task(:encrypt_password_settings => :environment) do
    settings = Setting.all.select{|setting| setting.type == 'password' }
    updated_settings =  settings.select do |setting|
      begin
        setting.value
        false      
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        # setting is not encoded yet!
        setting.value = setting.untypecasted_value
        setting.save!
      end
    end
    
    p "Updated settings: #{updated_settings.inspect}"
  end
end
