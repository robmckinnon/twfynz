class CreateBillEvents < ActiveRecord::Migration
  def self.up
    create_table :bill_events, :options => 'default charset=utf8' do |t|
      t.integer :bill_id
      t.string :name
      t.date :date
      t.string :source_type
      t.integer :source_id

      t.timestamps
    end

    NzlEvent.all.each do |nzl_event|
      event = BillEvent.create_from_nzl_event(nzl_event)
      event.save! if event
    end

    Bill.all.each do |bill|
      events = BillEvent.create_from_bill(bill)
      events.each {|e| e.save!}
    end
  end

  def self.down
    drop_table :bill_events
  end
end
