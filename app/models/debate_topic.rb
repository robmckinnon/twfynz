class DebateTopic < ActiveRecord::Base

  belongs_to :topic, :polymorphic => true
  belongs_to :debate

  def formerly_part_of_bill
    if topic.is_a? Bill
      topic.formerly_part_of
    else
      nil
    end
  end

  def formerly_part_of_bill_name
    if topic.is_a? Bill
      topic.formerly_part_of.bill_name
    else
      nil
    end
  end

  def bill_name
    if topic.is_a? Bill
      topic.bill_name
    else
      nil
    end
  end
end
