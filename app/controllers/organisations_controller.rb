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
      render :text => '<a href="http://theyworkforyou.co.nz/organisations/'+organisation.slug+'">'+organisation.name+'</a>'
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
    if @organisation
      @business_item_name_to_submissions = @organisation.business_item_name_to_submissions
      @count_of_mentions = @organisation.count_of_mentions
      @donations_total = @organisation.donations_total
    else
      render :template => 'organisations/no_organisation_found'
    end
  end

  def show_organisation_mentions
    name = params[:name]
    @organisation = Organisation.find_by_slug(name)
    @contribution_in_groups_by_debate = @organisation.find_mentions
  end

  def new_organisation
    if admin?
      @organisation = Organisation.new :name => params[:name]
    else
      render :text => ''
    end
  end

  def edit_organisation
    if admin?
      name = params[:name]
      @organisation = Organisation.find_by_slug(name)
    else
      render :text => ''
    end
  end

  def update_organisation
    if admin?
      name = params[:name]
      @organisation = Organisation.find_by_slug(name)
      @organisation.update_attributes!(params[:organisation])
      redirect_to :action => "show_organisation"
    else
      render :text => ''
    end
  end

  def create_organisation
    if admin?
      if params[:organisation][:url].blank?
        params[:organisation][:url] = nil
      end
      @organisation = Organisation.new(params[:organisation])
      if @organisation.save
        flash[:notice] = 'Organisation was successfully created.'
        redirect_to(show_organisation_url(:name => @organisation.slug))
      else
        render :action => "new_organisation"
      end
    else
      render :text => ''
    end
  end
end
