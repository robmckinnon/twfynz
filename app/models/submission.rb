class Submission < ActiveRecord::Base

  belongs_to :business_item, :polymorphic => true
  belongs_to :submitter, :polymorphic => true
  belongs_to :committee

  before_validation_on_create :populate_committee_id,
      :populate_business_item

  before_validation :create_submitter_if_is_from_organisation

  after_save :expire_cached_pages

  def self.count_by_business_item item
    if item && item.is_a?(Bill)
      count_by_sql("SELECT COUNT(*) FROM submissions WHERE business_item_id = #{item.id} and business_item_type = 'Bill'")
    else
      0
    end
  end

  def self.find_all_by_business_item item
    if item && item.is_a?(Bill)
      Submission.find_all_by_business_item_id_and_business_item_type(item.id, Bill.name)
    else
      nil
    end
  end

  def populate_submitter_id
    if (submitter_name and (submitter_id == nil))
      organisation = Organisation.from_name(submitter_name)
      if organisation
        self.submitter_id = organisation.id
        self.submitter_type = Organisation.name
        self.submitter_url = organisation.url
        self.is_from_organisation = 1
        return 'yes'
      else
        self.submitter_id = nil
        self.submitter_type = nil
        self.is_from_organisation = 0
      end
    end
    return 'no'
  end

  protected

    def uncache path
      if File.exist?(path)
        puts 'deleting: ' + path.sub(RAILS_ROOT + '/tmp/cache/theyworkforyou.co.nz', '')
        File.delete(path)
      end
    end

    def expire_cached_pages
      return unless ActionController::Base.perform_caching

      cache = RAILS_ROOT + '/tmp/cache/theyworkforyou.co.nz'

      if submitter
        uncache "#{cache}/organisations/#{submitter.slug}.cache"
      end

      uncache "#{cache}/organisations.cache"
    end

    def create_submitter_if_is_from_organisation
      if self.submitter_id.nil?
        if (self.is_from_organisation && self.is_from_organisation != 0)
          organisation = Organisation.from_name(submitter_name)
          unless organisation
            if submitter_url.blank?
              organisation = Organisation.new :name => submitter_name
            else
              organisation = Organisation.new :name => submitter_name,
                  :url => submitter_url
            end
            organisation.save!
          end
        end
      end
      populate_submitter_id
    end

    def committee_name= committee_name
      @committee_name = committee_name
    end

    def populate_business_item
      if business_item_name
        if business_item_name.ends_with? 'Bill'
          bill = Bill.from_name_and_date business_item_name, date
          if bill
            self.business_item_id = bill.id
            self.business_item_type = Bill.name
          else
            raise 'no bill found for: ' + business_item_name
          end
        else
          self.business_item_id = nil
          self.business_item_type = nil
        end
      else
        raise 'business_item_name must be specified'
      end
    end

    def populate_committee_id
      if @committee_name
        committee = Committee.from_name(@committee_name)
        if committee
          self.committee_id = committee.id
        else
          raise 'no committee found for: ' + @committee_name
        end
        @committee_name = nil
      elsif committee_id == nil
        raise 'committee_name must be specified'
      end
    end
end
