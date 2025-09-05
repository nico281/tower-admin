class ResidentMailer < ApplicationMailer
  def invitation(resident)
    @resident = resident
    @company = resident.company
    @building = resident.building
    @invitation_url = accept_resident_invitation_url(
      token: resident.invitation_token,
      subdomain: @company.subdomain,
      host: ActionMailer::Base.default_url_options[:host],
      port: ActionMailer::Base.default_url_options[:port]
    )

    mail(
      to: @resident.email,
      subject: "Invitación para acceder al sistema de #{@company.name}"
    )
  end
end
