class AddAltLastAndAltImageToMps < ActiveRecord::Migration
  def self.up
    # add_column :mps, :image, :string
    # add_column :mps, :alt_image, :string
    # add_column :mps, :alt_last, :string
  end

  def self.down
    # Mp.find(:all).each do |mp|
      # unless mp.alt_image.blank?
        # mp.img = mp.alt_image
      # end
      # unless mp.alt_last.blank?
        # mp.last = mp.alt_last
      # end
      # mp.save!
    # end
    # remove_column :mps, :image
    # remove_column :mps, :alt_image
    # remove_column :mps, :alt_last
  end
end
