xml.results do
  xml.tag!('total_count', @user_count)
  for user in @users
    xml.subscription do
      xml.user_id(user.id)
      xml.user_login(user.login)
      xml.user_email_address(user.email_address)
    end
  end
end
