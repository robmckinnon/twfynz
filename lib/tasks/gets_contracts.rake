namespace :kiwimp do

  desc 'scrapes gets awarded contracts'
  task :gets => :environment do
    contracts = []
    1.upto(2351) {|i| contracts << GetsContract.new(i); puts i}
    File.open('contracts.yml', 'w') {|f| YAML.dump(contracts,f)}
  end

end