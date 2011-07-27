namespace :kiwimp do

  desc "corrects topic of third readings"
  task :correct_third_readings => :environment do
    debates = Debate.find(:all, :conditions => 'name like "%Third Readings%"')
    Debate.create_debate_topics debates
  end
end
