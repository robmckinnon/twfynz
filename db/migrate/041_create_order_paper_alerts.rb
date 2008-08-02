class CreateOrderPaperAlerts < ActiveRecord::Migration
  def self.up
    create_table :order_paper_alerts, :options => 'default charset=utf8' do |t|
      t.date :order_paper_date
      t.string :name
      t.date :alert_date
      t.string :url

      t.timestamps
    end

    add_index :order_paper_alerts, :name
    add_index :order_paper_alerts, :alert_date
  end

  def self.down
    drop_table :order_paper_alerts
  end
end
