module SubmissionsHelper

  def org_check_box submission
    form_for(submission) do |f|
      f.check_box :is_from_organisation
    end
  end
end
