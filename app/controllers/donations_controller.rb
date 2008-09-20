class DonationsController < ApplicationController

  def index
    @donations = Donation.paginate :page => params[:page], :order => 'donor_name asc'
  end

  def update_donation
    update
  end

  def update
    if admin?
      @donation = Donation.find(params[:id])
      if organisation_slug = params[:donation][:organisation_slug]
        organisation = Organisation.find_by_slug(organisation_slug)
        if organisation
          params[:donation].delete(:organisation_slug)
          params[:donation][:organisation_id] = organisation.id
          @donation.update_attributes(params[:donation])
          @donation.reload
        end
      end
      render :partial => 'donations/donation', :object => @donation
    else
      render :text => ''
    end
  end

end
