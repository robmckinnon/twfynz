class PersistedFilesController < ApplicationController

  def index
    if admin?
      @persisted_files = PersistedFile.all.in_groups_by(&:debate_date).sort {|a,b| b.first.debate_date <=> a.first.debate_date}
    else
      render :text => 'Unauthorized', :status => 401
    end
  end
end
