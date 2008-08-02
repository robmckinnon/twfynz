class BillEvent < ActiveRecord::Base

  belongs_to :bill
  belongs_to :source, :polymorphic => true

  class << self

    def create_from_nzl_event nzl_event
      if nzl_event.about_type == 'Bill' && nzl_event.about_id
        returning(BillEvent.new) do |e|
          e.bill_id     = nzl_event.about_id
          e.name        = nzl_event.version_stage
          e.date        = nzl_event.version_date
          e.source_type = 'NzlEvent'
          e.source_id   = nzl_event.id
        end
      else
        nil
      end
    end

    def create_from_bill bill
      events = []
      bill.events_by_date.each do |date_and_stage|
        date = date_and_stage[0]
        stage = date_and_stage[1]
        events << create_from_bill_stage(bill, stage, date)
      end
      events
    end

    def create_from_bill_stage bill, stage, date
      returning(BillEvent.new) do |e|
        e.bill_id     = bill.id
        e.name        = stage
        e.date        = date
      end
    end

    def refresh_events_from_bill bill
      create_from_bill(bill).each do |event|
        existing = find_by_date_and_name_and_bill_id(event.date, event.name, event.bill_id)
        event.save! unless existing
      end
    end
  end

  def <=> event
    other_date = event.date
    comparison = date <=> other_date
    if comparison == 0
      other_name = event.name
      if name[/First/] && (other_name[/Second/] or other_name[/Third/])
        comparison = -1
      elsif name[/Second/] && (other_name[/Third/])
        comparison = -1
      elsif name[/Second/] && (other_name[/First/])
        comparison = +1
      elsif name[/Third/] && (other_name[/First/] or other_name[/Second/])
        comparison = +1
      else
        comparison = 0
      end
    end
    comparison
  end
end
