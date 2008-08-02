require File.dirname(__FILE__) + '/../spec_helper'

def answers_from_question_time_alert
  receiving_address = 'receiving_address.co.nz'
  sending_host = 'sending_host.co.nz'
  sending_address = 'sending_address.co.nz'

  %Q|Delivered-To: #{receiving_address}
Received: from #{sending_host} (unknown [202.68.89.84])
  by theyworkforyou.co.nz (Postfix) with ESMTP id 6569A49494B
  for <#{receiving_address}>; Sat, 19 Jul 2008 00:46:22 +0100 (BST)
Received: from mail pickup service by #{sending_host} with Microsoft SMTPSVC;
   Sat, 19 Jul 2008 11:44:16 +1200
thread-index: AcjpMDCRhKwa0YToRgyIp+8tJZRrFA==
Thread-Topic: NZ Parliament: Questions for oral answer - answers from question time 6:00pm
From: "Alerts System" <#{sending_address}>
To: <#{receiving_address}>
Subject: NZ Parliament: Questions for oral answer - answers from question time 6:00pm
Date: Sat, 19 Jul 2008 11:44:16 +1200
Message-ID: <614CCA594CA54214BB2993C0554F0DD6@psinternet.parliament.nz>
MIME-Version: 1.0
Content-Type: multipart/alternative;
  boundary="----=_NextPart_000_02DF_01C8E994.C5C65440"
X-Mailer: Microsoft CDO for Windows 2000
Content-Class: urn:content-classes:message
Importance: normal
Priority: normal
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.3790.4073
X-OriginalArrivalTime: 18 Jul 2008 23:44:16.0338 (UTC) FILETIME=[309D5B20:01C8E930]

This is a multi-part message in MIME format.

------=_NextPart_000_02DF_01C8E994.C5C65440
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

The following documents matching your alert criteria have been
published.

*	18/Jul/2008 - Provisional Order Paper for Tuesday, 22 July 2008
<http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1>

  _____

This email has been sent to you as a result of the alert profile 'Order
Paper 11:30am' that has been created for your email address on the NZ
Parliament website. To suspend, unsubscribe or edit the alert please use
the links below.


Manage your Alerts <http://www.parliament.nz/en-NZ/Alerts/Maintenance/>
Edit this Alert
<http://www.parliament.nz/en-NZ/Alerts/Maintenance/CreateAlert.htm?Alert
ID=28>

------=_NextPart_000_02DF_01C8E994.C5C65440
Content-Type: text/html;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

<p>The following documents matching your alert criteria have been published.</p>
<ul>
  <li>18/Jul/2008 -
        <a href="http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1">Provisional Order Paper for Tuesday, 22 July 2008</a></li>
</ul>
<hr>
<p>This email has been sent to you as a result of the alert profile 'Order Paper 11:30am' that has been created for your email address on the NZ Parliament website.  To suspend, unsubscribe or edit the alert please use the links below.</p>
<br>
<a href="http://www.parliament.nz/en-NZ/Alerts/Maintenance/">Manage your Alerts</a>
<br>
<a href="http://www.parliament.nz/en-NZ/Alerts/Maintenance/CreateAlert.htm?AlertID=28">Edit this Alert</a>
------=_NextPart_000_02DF_01C8E994.C5C65440--|
end

def order_paper_alert name, date, url
  receiving_address = 'receiving_address.co.nz'
  sending_host = 'sending_host.co.nz'
  sending_address = 'sending_address.co.nz'

  %Q|Delivered-To: #{receiving_address}
Received: from #{sending_host} (unknown [202.68.89.84])
  by theyworkforyou.co.nz (Postfix) with ESMTP id 6569A49494B
  for <#{receiving_address}>; Sat, 19 Jul 2008 00:46:22 +0100 (BST)
Received: from mail pickup service by #{sending_host} with Microsoft SMTPSVC;
   Sat, 19 Jul 2008 11:44:16 +1200
thread-index: AcjpMDCRhKwa0YToRgyIp+8tJZRrFA==
Thread-Topic: NZ Parliament: Order Paper 11:30am
From: "Alerts System" <#{sending_address}>
To: <#{receiving_address}>
Subject: NZ Parliament: Order Paper 11:30am
Date: Sat, 19 Jul 2008 11:44:16 +1200
Message-ID: <614CCA594CA54214BB2993C0554F0DD6@psinternet.parliament.nz>
MIME-Version: 1.0
Content-Type: multipart/alternative;
  boundary="----=_NextPart_000_02DF_01C8E994.C5C65440"
X-Mailer: Microsoft CDO for Windows 2000
Content-Class: urn:content-classes:message
Importance: normal
Priority: normal
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.3790.4073
X-OriginalArrivalTime: 18 Jul 2008 23:44:16.0338 (UTC) FILETIME=[309D5B20:01C8E930]

This is a multi-part message in MIME format.

------=_NextPart_000_02DF_01C8E994.C5C65440
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

The following documents matching your alert criteria have been
published.

*	18/Jul/2008 - Provisional Order Paper for Tuesday, 22 July 2008
<http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1>

  _____

This email has been sent to you as a result of the alert profile 'Order
Paper 11:30am' that has been created for your email address on the NZ
Parliament website. To suspend, unsubscribe or edit the alert please use
the links below.


Manage your Alerts <http://www.parliament.nz/en-NZ/Alerts/Maintenance/>
Edit this Alert
<http://www.parliament.nz/en-NZ/Alerts/Maintenance/CreateAlert.htm?Alert
ID=28>

------=_NextPart_000_02DF_01C8E994.C5C65440
Content-Type: text/html;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit

<p>The following documents matching your alert criteria have been published.</p>
<ul>
  <li>#{date} -
        <a href="#{url}">#{name}</a></li>
</ul>
<hr>
<p>This email has been sent to you as a result of the alert profile 'Order Paper 11:30am' that has been created for your email address on the NZ Parliament website.  To suspend, unsubscribe or edit the alert please use the links below.</p>
<br>
<a href="http://www.parliament.nz/en-NZ/Alerts/Maintenance/">Manage your Alerts</a>
<br>
<a href="http://www.parliament.nz/en-NZ/Alerts/Maintenance/CreateAlert.htm?AlertID=28">Edit this Alert</a>
------=_NextPart_000_02DF_01C8E994.C5C65440--|
end

describe ParliamentAlertReceiver do
  describe "when order paper alert is received" do
    before do
      @alert_date = %Q|18/Jul/2008|
      @name = %Q|Provisional Order Paper for Tuesday, 22 July 2008|
      @url = %Q|http://www.parliament.nz/en-NZ/?document=00HOHOrderPaper1|
      @raw_email = order_paper_alert @name, @alert_date, @url
      @alert = mock('alert')
    end

    it 'should send twitter update' do
      OrderPaperAlert.should_receive(:new).with(anything).and_return @alert
      @alert.should_receive(:tweet_alert)
      ParliamentAlertReceiver.receive(@raw_email)
    end

    describe "on creation of new order paper alert" do
      before do
        @alert.stub!(:tweet_alert)
      end
      it 'should set name correctly' do
        OrderPaperAlert.should_receive(:new).with(hash_including(:name=>@name)).and_return @alert
        ParliamentAlertReceiver.receive(@raw_email)
      end
      it 'should set date correctly' do
        order_paper_date = Date.new(2008,7,22)
        OrderPaperAlert.should_receive(:new).with(hash_including(:order_paper_date=>order_paper_date)).and_return @alert
        ParliamentAlertReceiver.receive(@raw_email)
      end
      it 'should set url correctly' do
        OrderPaperAlert.should_receive(:new).with(hash_including(:url=>@url)).and_return @alert
        ParliamentAlertReceiver.receive(@raw_email)
      end
      it 'should set date correctly' do
        alert_date = Date.new(2008,7,18)
        OrderPaperAlert.should_receive(:new).with(hash_including(:alert_date=>alert_date)).and_return @alert
        ParliamentAlertReceiver.receive(@raw_email)
      end
    end
  end

  describe "when answers from question time alert is received" do
    before do
      @raw_email = answers_from_question_time_alert
    end
    it 'should not create a new order paper alert' do
      OrderPaperAlert.should_not_receive(:new)
      ParliamentAlertReceiver.receive(@raw_email)
    end
  end
end
