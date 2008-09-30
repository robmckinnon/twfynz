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
end
