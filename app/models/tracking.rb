class Tracking < ActiveRecord::Base

  belongs_to :user
  belongs_to :item, :polymorphic => true

  validates_presence_of :user
  validates_presence_of :item

  before_validation_on_create :set_created_at_date, :default_booleans

  class << self
    def from_user_and_item user, item
      if (item and user)
        item_type = get_item_type item
        find_by_user_id_and_item_type_and_item_id user.id, item_type, item.id
      else
        nil
      end
    end

    def all_for_item item, user=nil
      item_type = get_item_type item
      trackings = find_all_by_item_id_and_item_type item.id, item_type
      if user
        trackings.sort! do |a,b|
          if a.user_id == user.id
            0
          elsif b.user_id == user.id
            1
          else
            a.user.login <=> b.user.login
          end
        end
      else
        trackings.sort! { |a,b| a.user.login <=> b.user.login }
      end
      trackings
    end

    protected
      def get_item_type item
        item_type = item.class
        while (item_type.superclass != ActiveRecord::Base)
          item_type = item_type.superclass
        end
        item_type.name
      end
  end

  protected

    def set_created_at_date
      self.created_at = (Time.now.utc + ActiveSupport::TimeZone.new("Auckland").utc_offset).to_date
    end

    def default_booleans
      self.tracking_on = 0 unless self.tracking_on
      self.email_alert = 0 unless self.email_alert
      self.include_in_feed = 0 unless self.include_in_feed
    end
end
