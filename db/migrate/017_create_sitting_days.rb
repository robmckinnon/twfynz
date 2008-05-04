class CreateSittingDays < ActiveRecord::Migration
  def self.up
    create_table :sitting_days, :options => 'default charset=utf8' do |t|
      t.column :date, :date
      t.column :has_oral_answers, :boolean
      t.column :has_advance, :boolean
      t.column :has_final, :boolean
    end
  end

  def self.down
    drop_table :sitting_days
  end
end
