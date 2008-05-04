class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes, :options => 'default charset=utf8' do |t|
      t.column :type, :string, :limit => 12
      t.column :vote_question, :text
      t.column :vote_result, :text
      t.column :ayes_tally, :integer
      t.column :noes_tally, :integer
      t.column :abstentions_tally, :integer
    end
  end

  def self.down
    drop_table :votes
  end
end
