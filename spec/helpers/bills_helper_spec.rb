require File.dirname(__FILE__) + '/../spec_helper'

describe BillsHelper do
  describe 'BillEvent' do
    before do
      @bill_event = mock(BillEvent)
      @bill_name = 'Web Bill'
      @date, @url = 'date', 'url'
    end

    describe 'sourced from parliament bill page' do
      def self.check_notification_description event_name, expected
        eval %Q|it 'should describe #{event_name} correctly' do
                  helper.bill_event_notification_description(@bill_name, '#{event_name}', @date, @url).should == %Q[#{expected}]
                end|
      end

      def self.reading_description reading
        %Q|<p>date: The <a href="url">Web Bill</a> had a #{reading} debate.</p><p>More details will be available after Parliament publishes the debate transcript.</p>|
      end

      check_notification_description 'Introduction',
          '<p>date: The <a href="url">Web Bill</a> was introduced to parliament.</p>'
      check_notification_description 'First Reading', reading_description('first reading')
      check_notification_description 'Second Reading', reading_description('second reading')
      check_notification_description 'Third Reading', reading_description('third reading')

      check_notification_description 'SC Reports', '<p>The select committee report due on date for the <a href="url">Web Bill</a>.</p>'
      check_notification_description 'Submissions Due',
          '<p>Public submissions are due by date for the <a href="url">Web Bill</a>.</p>'
    end

    describe 'sourced from NZL event' do
      describe 'when introduction text at NZL site' do
      end
      describe 'when reported text at NZL site' do
      end
    end
    describe 'sourced from completed bill debate with no vote' do
      describe 'when first reading debate' do
      end
    end
    describe 'sourced from completed bill debate with vote' do
    end
    describe 'sourced from uncompleted bill debate' do
      describe 'when first reading debate' do
      end
    end
    describe 'sourced from resumed bill debate' do
    end
  end
end
