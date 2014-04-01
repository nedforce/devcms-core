module Admin::UsersHelper
  def last_sign_in_at(user)
    user.last_sign_in_at.present? ? user.last_sign_in_at : I18n.t('users.unknown_last_sign_in_at')
  end

  def has_news_letter_subscription(user)
    user.newsletter_subscription_count.to_i > 0 ? 'yes' : 'no'
  end

  def user_type user
    user.type == 'PrivilegedUser' ? I18n.t('users.cms_user') : I18n.t('users.normal_user')
  end
end