class OrganisationsController < ApplicationController

  caches_action :index, :show_organisation, :show_organisation_mentions

  layout "organisations_layout"

  in_place_edit_for :organisation, :wikipedia_url
  in_place_edit_for :organisation, :alternate_names

  def index
    @organisations = Organisation.find(:all).sort_by(&:count_of_mentions).reverse
  end

  def find_organisation
    name = params[:q]
    organisation = Organisation.from_name(name) if name
    if organisation
      render :text => organisation.url
    else
      render :text => ''
    end
  end

  def edit_organisations
    if admin?
      @organisations = Organisation.find(:all).sort_by { |o| o.name.downcase }
    else
      render :text => ''
    end
  end

  def show_organisation
    name = params[:name]
    @organisation = Organisation.find_by_slug(name)

    @business_item_name_to_submissions = @organisation.submissions.group_by do |submission|
      if submission.business_item
        submission.business_item.bill_name
      else
        submission.business_item_name
      end
    end

    unless @organisation
      render :template => 'organisations/no_organisation_found'
    end
  end

  def show_organisation_mentions
    name = params[:name]
    @organisation = Organisation.find_by_slug(name)
    @contribution_in_groups_by_debate = @organisation.find_mentions
  end

end
