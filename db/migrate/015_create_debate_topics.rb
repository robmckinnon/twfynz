class CreateDebateTopics < ActiveRecord::Migration

  def self.up
    create_table :debate_topics, :options => 'default charset=utf8' do |t|
      t.column :debate_id, :integer, :null => false
      t.column :topic_type, :string, :limit => 15
      t.column :topic_id, :integer, :null => false
    end

    add_index :debate_topics, :debate_id
  end

  def self.down
    drop_table :debate_topics
  end
end
