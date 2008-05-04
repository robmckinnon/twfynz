class PlacesController < ApplicationController

  def index
    @places = Geoname.find_all_places
  end

  def show_place
    name = params[:name]
    @place = Geoname.find_by_slug(name)
    zoom = @place.feature_code == 'PPLX' ? 11 : 7
    @map = make_map [[@place,[]]], @place.latitude, @place.longitude, zoom
    @contribution_in_groups_by_debate = @place.find_mentions
  end
end
