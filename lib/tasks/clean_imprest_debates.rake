
namespace :kiwimp do

  desc 'convert imprest supply debates to third reading debates'
  task :clean_imprest => [:environment] do
    debates = Debate.find_by_sql("select * from debates where name like 'Appropriation%' and type != 'SubDebate'") ; nil
    subdebates = debates.map {|x| x.sub_debates}.flatten ; nil
    empty_debates = subdebates.select{|x| x.contributions.empty?} ; nil
    parent_debates = empty_debates.map(&:parent) ; nil
    imprest_debates = parent_debates.map{|x| x.sub_debates }.flatten.select {|x| x.name == 'Imprest Supply Debate'} ; nil
    events = imprest_debates.map{|x| x.bill_events}.flatten.select {|x| x.name == 'Imprest Supply Debate'} ; nil
    events.each {|x| x.name = 'Third Reading' ; x.save } ; nil
    imprest_debates.each {|x| x.name = 'Third Reading' ; x.save } ; nil

    empty_debates.each {|x| x.destroy} ; nil
    events.each {|x| x.bill.save}
  end

end
