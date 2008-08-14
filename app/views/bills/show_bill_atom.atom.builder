atom_feed do |feed|
  feed.title @bill.bill_name
  feed.updated @bill_events.first.created_at unless @bill_events.empty?
  @bill_events.each do |bill_event|
    feed.entry(bill_event, :url=>bill_event_url(bill_event)) do |entry|
      entry.title "#{@bill.bill_name}-#{bill_event.name}"
      entry.content(bill_event_description(bill_event), :type => 'html')
      entry.author do |author|
        author.name("TheyWorkForYou.co.nz")
      end
    end
  end
end
