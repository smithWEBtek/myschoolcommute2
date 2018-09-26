class UserMailer < ApplicationMailer
  default from: 'noreply@masaferoutessurvey.org'

  def new_user_email(user)
    @recipients = Rails.application.secrets.email_recipients
    @user = user

    mail(
      to: @recipients,
      subject: 'New User Signup'
    )
  end

end
