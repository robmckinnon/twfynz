class NotificationMailer < ActionMailer::Base

  def forgot_password(to, login, pass, sent_at = Time.now)
    @subject    = "Your new password is ..."
    @body['login'] = login
    @body['pass'] = pass
    @recipients = to
    @from       = 'support@theyworkforyou.co.nz'
    @sent_on    = sent_at
    @headers    = {}
  end

end
