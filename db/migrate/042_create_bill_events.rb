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

    BillEvent.record_timestamps = false

    NzlEvent.all.each do |nzl_event|
      event = BillEvent.create_from_nzl_event(nzl_event)
      if event
        event.set_created_and_updated_at_date_to_event_date
        event.save!
      end
    end

    bills = Bill.all
    # bills = [Bill.find_by_url('auckland_regional_amenities_funding')]
    bills.each do |bill|
      events = BillEvent.create_from_bill(bill)
      events.each do |event|
        event.set_created_and_updated_at_date_to_event_date
        event.save!
      end
    end

    BillEvent.record_timestamps = true
  end

  def self.down
    drop_table :bill_events
  end
end
