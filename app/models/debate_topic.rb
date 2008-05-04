class DebateTopic < ActiveRecord::Base

  belongs_to :topic, :polymorphic => true
  belongs_to :debate

end
