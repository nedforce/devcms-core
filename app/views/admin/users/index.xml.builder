xml.results do
  xml.tag!('total_count', @user_count)
  xml.users do
    for user in @users do
      xml.user do
        xml.id(user.id)
        xml.login(user.login)
        xml.first_name(user.first_name)
        xml.surname(user.surname)
        xml.sex(user.sex)
        xml.email_address(user.email_address)
        xml.created_at(user.created_at.strftime("%d-%m-%Y"))
        xml.newsletter_archives(user.newsletter_archives.sort_by { |archive| archive.title }.map { |archive| archive.title }.join(', '))
        xml.interests(user.interests.sort_by { |i| i.title }.map { |i| i.title }.join(', '))
        xml.status(user.blocked? ? 'vergrendeld' : '')
      end
    end
  end
end

