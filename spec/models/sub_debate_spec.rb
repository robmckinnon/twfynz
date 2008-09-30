require File.dirname(__FILE__) + '/../spec_helper'

describe SubDebate do
  describe 'in general' do
    it 'should return parent name' do
      debate = SubDebate.new
      parent = mock('parent',:name=>'name')
      debate.should_receive(:parent).twice.and_return parent
      debate.parent_name.should == 'name'
    end
  end

  describe 'when asked for bill' do
    describe 'and is about bill' do
      it 'should return bill' do
        subdebate = SubDebate.new
        bill = mock('government_bill')
        bill.should_receive(:is_a?).with(Bill).and_return true
        subdebate.stub!(:about).and_return bill
        subdebate.bill.should == bill
      end
    end
    describe 'and is not about bill' do
      it 'should return nil' do
        subdebate = SubDebate.new
        portfolio = mock('portfolio')
        portfolio.should_receive(:is_a?).with(Bill).and_return false
        subdebate.stub!(:about).and_return portfolio
        subdebate.bill.should be_nil
      end
    end
  end

  describe "creating url slug for bill subdebate" do
    it 'should shorten "Consideration of Interim Report of Transport and Industrial Relations Committee" to "consideration_of_interim_report"' do
      assert_slug_correct "Consideration of Interim Report of Transport and Industrial Relations Committee", 'consideration_of_interim_report'
    end

    it 'should shorten "Referral to Transport and Industrial Relations Committee" to "referral_to_committee"' do
      assert_slug_correct "Referral to Transport and Industrial Relations Committee", 'referral_to_committee'
    end

    it 'should fix "Second ReadingThird Reading" to be "second_and_third_reading"' do
      assert_slug_correct "Second ReadingThird Reading", 'second_and_third_reading'
    end

    it 'should handle other text as usual' do
      assert_slug_correct 'Third Reading', 'third_reading'
    end

    def assert_slug_correct name, expected
      debate = SubDebate.new(:name => name, :date => '2008-04-01', :publication_status => 'U')
      debate.stub!(:about).and_return mock_model(Bill)
      debate.stub!(:make_url_category_text).and_return ''
      debate.create_url_slug
      debate.url_slug.should == expected
    end

  end

  describe "creating url slug for non-bill subdebate" do
    def assert_slug_correct parent_name, name, category_or_slug, slug=nil
      debate = SubDebate.new(:name => name, :date => '2008-04-01', :publication_status => 'U')
      debate.stub!(:about).and_return nil
      debate.stub!(:parent).and_return mock_model(ParentDebate, :name => parent_name)
      debate.create_url_slug
      debate.url_category.should == category_or_slug if slug
      debate.url_slug.should == (slug ? slug : category_or_slug)
    end

    it 'should create url_category and url_slug' do
      assert_slug_correct 'Points of Order', 'Mispronunciation—Māori Language and Members’ Names', 'points_of_order', 'mispronunciation'              # http://theyworkforyou.co.nz/debates/2008/apr/09/02
      assert_slug_correct 'Visitors', "Australia—Attorney-General", 'visitors', 'australia'
      assert_slug_correct 'Urgent Debates Declined', 'Auckland International Airport—Canada Pension Plan Investment Board Bid', 'urgent_debates_declined', 'auckland_international_airport'  # http://theyworkforyou.co.nz/debates/2008/apr/15/20
      assert_slug_correct 'Tabling of Documents', 'Driving Incident', 'tabling_of_documents', 'driving_incident'                                      # http://theyworkforyou.co.nz/debates/2008/apr/02/23
      assert_slug_correct 'Obituaries', 'Rt Hon Fraser MacDonald Colman QSO', 'obituaries', 'rt_hon_fraser_macdonald_colman_qso'                      # http://theyworkforyou.co.nz/debates/2008/apr/15/03
      assert_slug_correct 'Speaker’s Rulings', 'Personal Explanations—Member’s Word Must Be Accepted', 'speakers_rulings', 'personal_explanations'    # http://theyworkforyou.co.nz/debates/2008/apr/01/02
      assert_slug_correct 'Motions', 'Tongariro Tragedy—Elim Christian College', 'motions', 'tongariro_tragedy'                                       # http://theyworkforyou.co.nz/debates/2008/apr/16/01
      assert_slug_correct 'Personal Explanations', 'Electoral Finance Act—Third Party Registration', 'personal_explanations', 'electoral_finance_act' # http://theyworkforyou.co.nz/debates/2008/apr/02/21
      assert_slug_correct 'Appointments', 'Chief Ombudsman', 'appointments', 'chief_ombudsman' # http://theyworkforyou.co.nz/debates/2008/apr/17/17
      assert_slug_correct 'Urgent Debates', 'Hawke’s Bay District Health Board—Conflicts of Interest Report', 'urgent_debates', 'hawkes_bay_district_health_board' # http://theyworkforyou.co.nz/debates/2008/mar/18/25
      assert_slug_correct 'Privilege', 'Contempt of House—Apology from Hon Matt Robson', 'privilege', 'contempt_of_house'                             # http://theyworkforyou.co.nz/debates/2007/mar/13/02
      assert_slug_correct 'Speaker’s Statements', 'Microphones in Chamber—Fault', 'speakers_statements', 'microphones_in_chamber'                     # http://theyworkforyou.co.nz/debates/2007/sep/19/26
      assert_slug_correct 'Resignations', 'Dianne Yates, NZ Labour', 'resignations', 'dianne_yates_nz_labour'                                         # http://theyworkforyou.co.nz/debates/2008/apr/01/04
      assert_slug_correct 'Ministerial Statements', 'Fiji—High Commissioner for New Zealand', 'ministerial_statements', 'fiji'                        # http://theyworkforyou.co.nz/debates/2007/jun/14/03
      assert_slug_correct 'Adjournment', 'Sittings of the House', 'adjournment', 'sittings_of_the_house'                                              # http://theyworkforyou.co.nz/debates/2007/dec/18/29
      assert_slug_correct 'Parliamentary Service Commission', 'Membership', 'parliamentary_service_commission', 'membership'                          # http://theyworkforyou.co.nz/debates/2008/feb/19/23
      assert_slug_correct 'Business of Select Committees', 'Meetings', 'business_of_select_committees', 'meetings'                          # http://theyworkforyou.co.nz/debates/2006/nov/15/02
    end

    it 'should abbreviate amended answers' do
      assert_slug_correct 'AMENDED ANSWERS TO ORAL QUESTIONS', "Question No. 11 to Minister", 'amended_answers'
      assert_slug_correct 'Amended Answers to Oral Questions', "Question No. 11 to Minister", 'amended_answers'
    end

    it 'should abbreviate New Zealand to nz, and " - " to "_"' do
      assert_slug_correct 'Australia - New Zealand Political Exchange—Members', 'Australia—Standing Committee on Economics, Finance and Public Administration', 'australia_nz_political_exchange'
    end

    it 'only use name up to "—"' do
      assert_slug_correct 'Conduct in the House—Standards', 'Motion of No Confidence—Leave to Move', 'conduct_in_the_house'
    end
  end
end

=begin
other cases

- AMENDED ANSWERS TO ORAL QUESTIONS | Question No. 11 to Minister
- AMENDED ANSWERS TO ORAL QUESTIONS | Question No. 12 to Minister
- AMENDED ANSWERS TO ORAL QUESTIONS | Question No. 12 to Minister, 23 October
- AMENDED ANSWERS TO ORAL QUESTIONS | Question No. 3 to Minister
- AMENDED ANSWERS TO ORAL QUESTIONS | Question No. 7 to Minister
- Adjournment | Sittings of the House
- Amended Answers to Oral Questions | Question No. 10 to Minister
- Amended Answers to Oral Questions | Question No. 11 to Minister, 4 April
- Amended Answers to Oral Questions | Question No. 12 to Minister
- Amended Answers to Oral Questions | Question No. 4 to Minister, 11 May
- Amended Answers to Oral Questions | Question No. 7 to Minister
- Amended Answers to Oral Questions | Question No. 8 to Minister, 2 May, and Question No. 3 to Minister, 3 May
- Amended Answers to Oral Questions | Question No. 9 to Minister
- Amended Answers to Oral Questions | Question No. 9 to Minister, 12 May 2005
- Amended answers to Oral Questions | Question No. 10 to Minister, 11 October
- Amended answers to Oral Questions | Question No. 10 to Minister, 28 February
- Amended answers to Oral Questions | Question No. 12 to Minister, 12 March
- Amended answers to Oral Questions | Question No. 12 to Minister, 15 August
- Amended answers to Oral Questions | Question No. 12, 16 August
- Amended answers to Oral Questions | Question No. 4 to Minister, 6 September
- Amended answers to Oral Questions | Question No. 7 to Minister, 15 November
- Amended answers to Oral Questions | Question No. 7 to Minister, 23 March
- Amended answers to Oral Questions | Question No. 7 to Minister, 26 October
- Amended answers to Oral Questions | Question No. 8 to Minister, 13 February
- Appointments | Abortion Supervisory Committee
- Appointments | Assistant Speaker
- Appointments | Assistant Speakers
- Appointments | Chairperson of Commonwealth Local Government Forum
- Appointments | Chief Ombudsman
- Appointments | Clerk of the House of Representatives
- Appointments | Deputy Police Complaints Authority
- Appointments | Deputy Speaker
- Appointments | Ombudsman
- Appointments | Parliamentary Commissioner for the Environment
- Appointments | Police Complaints Authority
- Appointments | Representation Commission
- "Australia - New Zealand Political Exchange—Members | Australia—Standing Committee on Economics, Finance and Public Administration"
- Budget Statement | Budget Debate
- Budget Statement | Procedure
- Business of Select Committees | Meetings
- Business of Select Committees | Reporting Dates
- "Conduct in the House—Standards | Motion of No Confidence—Leave to Move"
- Debate on Crown Entities, Public Organisations, and State Enterprises | In Committee
- "Driving-related Deaths—Potential Government Reaction | Corrections, Minister—Possible Resignation"
- Election Petition | Tauranga
- Estimates Debate | In Committee
- Financial Review Debate | In Committee
- "Government Business—Procedure | Parliamentary Press Gallery—Parliamentary Complex"
- "Hone T\xC5\xABwhare | Hon Herbert John Walker CMG"
- "Housing—Replies to Questions | Questions for Oral Answer—Interruptions"
- "India—Parliamentary Delegation, Haryana State Legislative Assembly | Republic of Indonesia—Parliamentary Delegation, House of Representatives"
- Inquiry | Consideration of Report of Foreign Affairs, Defence and Trade Committee
- Inquiry | Inquiry into New Zealand's Relationship with Latin America
- Intelligence and Security Committee | Membership
- "Medal Ceremony—Notification | Inter-Parliamentary Union—Freedom of Speech"
- "Ministerial Statements | Capital and Coast District Health Board—Appointment of Crown Monitor"
- "Ministerial Statements | Fiji—High Commissioner for New Zealand"
- "Ministerial Statements | Fiji—Unconstitutional Actions"
- "Ministerial Statements | Lebanon—Israeli Bombing of United Nations Post"
- "Motion of No Confidence—Leave to Move | Motion Without Notice—Leave to Move"
- "Motions | Beaconsfield Gold Mine—Rescue of Miners"
- "Motions | Boating Tragedy—Foveaux Strait"
- Motions | Cluster Munitions
- "Motions | Columbia, Revolutionary Armed Forces—Hostages"
- "Motions | Family Support Tax Credit—Increase"
- "Motions | Hungarian Revolution—50th Anniversary"
- "Motions | Lions Club of New Zealand Parliament—Lions District 202H Wellington Project Award"
- "Motions | Mark Inglis—Conquest of Mount Everest"
- "Motions | Military Awards—Victoria Cross, Gallantry Decoration, Gallantry Medal"
- "Motions | Myanmar—Condemnation of Military Dictatorship"
- "Motions | New Zealand Commonwealth Games Team—Recognition"
- "Motions | Nobel Peace Prize 2007—Role of New Zealand Scientists"
- "Motions | Nuclear-Free Legislation—20th Anniversary"
- "Motions | Palestinian Parliament—Arrest of Members"
- "Motions | Parthenon (Elgin) Marbles—Return to Greece"
- Motions | Rugby World Cup 2011
- "Motions | Sir Keith Rodney Park GCB, KBE, MC and Bar, DFC—Memorial"
- "Motions | Snow Event—South Canterbury"
- "Motions | Terrorist Attack—11 September 2001"
- "Motions | Terrorist Attack—September 11, 2001"
- "Motions | Tibet—Protests"
- "Motions | Tibet—Violence and Riots"
- "Motions | Tongariro Tragedy—Elim Christian College"
- "Motions | Zimbabwe—Deteriorating Situation Under Mugabe Regime"
- Obituaries | Derek Lovell
- "Obituaries | Dorothy H\xC5\xABhana (Bubbles) Mihinui"
- Obituaries | Helen Duncan
- Obituaries | His Highness MalietoaTanumafili II
- "Obituaries | His Majesty King Taufa’ahau Tupou IV, King of Tonga"
- Obituaries | Hon Dean Jack Eyre
- Obituaries | Hon Henry Robert Lapwood OBE
- Obituaries | Hon John Howard Falloon CNZM
- Obituaries | Hon Phillip Albert Amos QSOAmos, Hon Phillip Albert, QSO
- Obituaries | John (Jack) Wallace Ridley QSO
- Obituaries | John Belgrave DCNZM
- Obituaries | John Finlay Luxton QSO
- Obituaries | Lord Cooke of Thorndon
- "Obituaries | Most Reverend Max T\xC4\x81kuiraM\xC4\x81riu"
- Obituaries | Neil Joseph Morrison
- Obituaries | Professor Alan Graham MacDiarmid
- Obituaries | Rod David Donald
- Obituaries | Rt Hon David Russell Lange ONZ, CH
- Obituaries | Rt Hon Fraser MacDonald Colman QSO
- "Obituaries | Tumu P\xC5\xABtaura"
- "Ombudsman’s Report—Investigation into Criminal Justice Sector | Capital and Coast District Health Board—State of Health Services"
- "Parliamentary Press Gallery—Access to Parliamentary Complex | Personal Explanations—Member’s Word Must Be Accepted"
- Parliamentary Service Commission | Membership
- "Personal Explanations | Allegations—Inquiry"
- "Personal Explanations | Anzac Day Ceremony—Attendance"
- "Personal Explanations | Criminal Procedure Bill—Incorrect Reference"
- "Personal Explanations | Electoral Finance Act—Authorisation"
- "Personal Explanations | Electoral Finance Act—Third Party Registration"
- "Personal Explanations | Email—Apology"
- "Personal Explanations | Ingram Report—Statement"
- "Personal Explanations | Legal Aid—Refutation of Allegation"
- "Personal Explanations | Lobbies—Incident"
- "Personal Explanations | New Zealand First—Donation of Money"
- "Personal Explanations | Personal Comments—Erin Leigh"
- Personal Explanations | Question No. 5 to Minister
- Personal Explanations | Question No. 5 to Minister, 15 March
- "Personal Explanations | Question No. 5 to Minister—Correction"
- "Personal Explanations | Trip to East Timor—1995"
- "Personal Explanations | Withdrawal and Apology—Defying the Chair"
- "Personal Reflections and Unparliamentary Language—Principles for Intervention | Questions for Oral Answer—Ministerial Responsibility"
- "PlunketLine—Support | Question for Written Answer—Reply"
- "Points of Order | Aboriginals—Australian Government Apology"
- "Points of Order | Absence of Members from the House—Rules"
- "Points of Order | Allegations—Hon David Benson-Pope"
- "Points of Order | Appropriation (Parliamentary Expenditure Validation) Bill—Parliamentary Service Advice"
- "Points of Order | Auditor-General—Officers of Parliament Committee"
- "Points of Order | Auditor-General—Report"
- "Points of Order | Behaviour in Chamber—Bob Clarkson"
- "Points of Order | Broadcasting (2005 Election Broadcasting Reimbursement) Amendment Bill—Leave to Introduce"
- "Points of Order | Building Industry Reforms—Document Not Tabled"
- "Points of Order | Chamber—Ejection of Members"
- "Points of Order | Code of Conduct—Members of Parliament"
- "Points of Order | Dalai Lama—Visit to New Zealand"
- "Points of Order | Discharge of sessional order—Television coverage of the House"
- "Points of Order | Dog Control (Exemption of Farm Dogs) Amendment Bill—Introduction"
- "Points of Order | Election Advertising—Auditor-General's Report"
- "Points of Order | Election Advertising—Auditor-General’s Report"
- "Points of Order | Election Advertising—Auditor-General’s Report and Speaker’s Response"
- "Points of Order | Election Advertising—Reimbursement of Expenditure"
- "Points of Order | Election Expenses—Allegations of Misuse of Parliamentary Funding"
- "Points of Order | Electioneering—Public Funds"
- "Points of Order | Electoral (Integrity) Amendment Bill—Order of the Day Discharged"
- "Points of Order | Estimates—Select Committee Examination"
- "Points of Order | Fiji, Martial Law—Government Statement"
- "Points of Order | Gordon Copeland— Resignation from United Future"
- "Points of Order | Government Announcement—Media Embargo"
- "Points of Order | Government Notice of Motion No. 2—Intelligence and Security Committee"
- "Points of Order | Land Transport (Driver Licensing) Amendment Bill—Leave to Introduce"
- "Points of Order | Members’ Notice of Motion No. 3—Order of Business"
- "Points of Order | Member’s Bill—Leave to Introduce"
- "Points of Order | Minister’s Comments—Law and Order Committee"
- "Points of Order | Misleading Statement to the House—5 September 2007"
- "Points of Order | Mispronunciation—M\xC4\x81ori Language and Members’ Names"
- "Points of Order | New Zealand Nuclear Free Zone, Disarmament and Arms Control Act—20th Anniversary"
- "Points of Order | Obituary—Tumu P\xC5\xABtaura"
- "Points of Order | Orders of the Day—Standing Orders"
- "Points of Order | Overseas Investment (Restriction on Foreign Ownership) Bill—Introduction and First Reading"
- "Points of Order | Parliament Buildings—Public Access"
- "Points of Order | Parliamentary Press Gallery—Access to Parliamentary Complex"
- "Points of Order | Parliamentary Press Gallery—Parliamentary Complex"
- "Points of Order | Party Leaders’ Staff—Ministerial Responsibility"
- "Points of Order | Party Votes—Proxy"
- "Points of Order | Personal Explanation—Keith Locke"
- "Points of Order | Petition—Microchipping of Dogs"
- "Points of Order | PlunketLine—Funding"
- Points of Order | Question No. 12 to Minister
- "Points of Order | Question No. 2 to Minister, 21 February—Acceptability of Questions"
- "Points of Order | Question No. 7 to Minister, 1 May—Incorrect Answer"
- "Points of Order | Question No. 9—Tabling of Document"
- "Points of Order | Question Time—Ministerial Delegations"
- "Points of Order | Question for Written Answer—Immigration"
- "Points of Order | Questions for Oral Answer—National Party"
- "Points of Order | Questions for Oral Answer—Publishing"
- "Points of Order | Questions for Oral Answer—Questions to Spokesperson"
- "Points of Order | Questions for Written Answer—Overdue"
- "Points of Order | Questions for Written Answer—Overdue Answers"
- "Points of Order | Questions for Written Answer—Overdue Replies"
- "Points of Order | Questions for Written Answer—Replies"
- "Points of Order | Referral to Privileges Committee—Hon David Benson-Pope"
- "Points of Order | Reserve Bank (Amending Primary Function of Bank) Amendment Bill— Leave to Introduce"
- "Points of Order | Reserve Bank (Amending Primary Function of Bank) Amendment Bill—Leave to Introduce"
- "Points of Order | Seating in Chamber—National Members"
- "Points of Order | Signage in the Chamber—New Zealand Labour Party"
- "Points of Order | Speaker’s Ruling—Questions for Oral Answer"
- "Points of Order | State Luncheon—Distribution of Party Political Material"
- "Points of Order | State Services,Minister—Lodging Questions"
- "Points of Order | Sub Judice Rule—Comments Made Outside House"
- "Points of Order | Supplementary Questions—Allocation"
- "Points of Order | Tabled Documents—Printing and Release"
- "Points of Order | Taito Phillip Field—Absence"
- "Points of Order | Taito Phillip Field—Proxy Vote"
- "Points of Order | Taito Phillip Field—Reference to Family"
- "Points of Order | Tauranga Court Case—Payment"
- "Points of Order | Television Coverage of Parliament—TV3"
- "Points of Order | Television New Zealand—Fiji Government"
- "Points of Order | Television Sets—Gallery"
- "Points of Order | Urgent Debate Declined—Well Child Freephone Service"
- "Points of Order | Urgent Debates—Criteria"
- "Points of Order | Urgent Question—High Court Ruling on Labtests Auckland"
- "Points of Order | Visitors—Hungarian Honorary Consul and Members of Hungarian Community"
- "Points of Order | Votes—Crimes (Substituted Section 59) Amendment Bill"
- "Points of Order | Written Questions—Requirements"
- Privilege | Consideration of Interim Report of Privileges Committee
- Privilege | Consideration of Report of Privileges Committee
- "Privilege | Contempt of House—Apology from Hon Matt Robson"
- "Privilege | Hon Matt Robson—Contempt of House"
- "Privilege | Officers of the House—Attendance at Employment Court"
- Privilege | Reflection on the Conduct of a Member
- "Privilege | Television New Zealand—Action Taken Against Chief Executive"
- "Privilege | Television New Zealand—Contempt of the House"
- "Privilege | Television New Zealand—Former Chief Executive"
- "Rayed Mohammed Abdullah Ali—Expulsion | State-owned Enterprises—Expansion into New Business Areas"
- "Report—Rt Hon Winston Peters and Accusations Against Iraqis | TV3 Transcript—Hon David Benson-Pope"
- Resignations | Ann Hartley, Labour
- Resignations | Clerk of the House of Representatives
- Resignations | Dianne Yates, NZ Labour
- Resignations | Dr Don Brash, New Zealand National
- Resignations | Georgina Beyer, Labour
- Resignations | Hon Brian Donnelly, New Zealand First
- Resignations | Hon Jim Sutton, Labour
- "Responses | Russell Hyslop—Statements made by Hon Dr Michael Cullen"
- "Select Committees—Official Business | Auditor-General—Officers of Parliament Committee"
- "Signage in the Chamber—New Zealand Labour Party | Select Committees—Official Business"
- "Speaker’s Rulings | Absence of Members from the House—Rules"
- "Speaker’s Rulings | Documents Tabled By Leave—Release"
- "Speaker’s Rulings | Ministerial Responsibility—Questions for Oral Answer"
- "Speaker’s Rulings | Mispronunciation—M\xC4\x81ori Language and Members’ Names"
- "Speaker’s Rulings | Party and Member Support—Ministerial Responsibility"
- "Speaker’s Rulings | Personal Explanations—Interjections"
- "Speaker’s Rulings | Personal Explanations—Member’s Word Must Be Accepted"
- "Speaker’s Rulings | Personal Reflections and Unparliamentary Language—Privilege"
- "Speaker’s Rulings | Personal Reflections—Member’s Right to Object"
- "Speaker’s Rulings | Points of Order—Personal Reflections"
- "Speaker’s Rulings | Privilege—Taito Phillip Field"
- "Speaker’s Rulings | Questions for Oral Answer—Acceptability of Questions"
- "Speaker’s Rulings | Questions for Oral Answer—Accountability Arrangements"
- "Speaker’s Rulings | Questions for Oral Answer—Interjections and Noise Level"
- "Speaker’s Rulings | Questions for Oral Answer—Publishing"
- "Speaker’s Rulings | Questions for Oral Answer—Questions to Members"
- "Speaker’s Rulings | Questions for Oral Answer—Quotations"
- "Speaker’s Rulings | Questions—Ministers’ Answers"
- "Speaker’s Rulings | Select Committees—Official Business"
- "Speaker’s Rulings | State Services, Minister—Lodging Questions"
- "Speaker’s Rulings | Sub Judice Rule—Operation"
- "Speaker’s Rulings | Supplementary Questions—Principles"
- "Speaker’s Statements | Chamber Sound—Testing"
- "Speaker’s Statements | Chamber—Behaviour"
- "Speaker’s Statements | Gordon Copeland— Resignation from United Future"
- "Speaker’s Statements | Microphones in Chamber—Fault"
- "Speaker’s Statements | Parliamentary Labour Party Membership—Taito Phillip Field"
- "Speaker’s Statements | Parliamentary Service—Speaker’s Role"
- "Speaker’s Statements | Search Warrant for Parliamentary and Electorate Offices—Interim Agreement"
- "Speaker’s Statements | Televising of Parliament—Testing"
- "Speaker’s statement | Election Advertising—Reimbursement of Expenditure"
- Supplementary Estimates | Imprest Supply Debate
- Tabling of Documents | Advice to Welsh Labour Party
- Tabling of Documents | Casino Legislation Voting Record
- Tabling of Documents | Code of Conduct for MPs
- Tabling of Documents | Code of Conduct for Members of Parliament
- Tabling of Documents | Conduct in the House; Photograph
- Tabling of Documents | Driving Incident
- Tabling of Documents | Early Childhood Education
- Tabling of Documents | Ferguson Lecture, 2006
- Tabling of Documents | Green Party Electoral Spending
- "Tabling of Documents | Hawke’s Bay District Health Board"
- Tabling of Documents | Housing New Zealand Financial Review
- Tabling of Documents | Leaks of emails
- "Tabling of Documents | Letter from the Royal Federation of New Zealand Justices’ Associations"
- Tabling of Documents | Letter to Minister of Housing
- Tabling of Documents | Ministry for the Environment Book Release
- Tabling of Documents | New Zealand First Campaign Funding
- Tabling of Documents | Newsletters
- Tabling of Documents | Parliamentary Rugby Trophy
- Tabling of Documents | Question No. 6 to Minister
- Tabling of Documents | Standing Orders
- Tabling of Documents | Telecom
- Tabling of Documents | Wine-box Inquiry
- Tabling of Documents | Work and Income Rules for Advances to Beneficiaries
- "Taito Phillip Field—Referral of Ingram Report to Privileges Committee | Taito Phillip Field—Leave to Move Motion"
- "Tibet—New Zealand’s Response | National Certificate of Educational Achievement—Report on First Analysis of Marking"
- "Tibet—Protests | National Certificate of Educational Achievement—Report on First Analysis of Marking"
- "United Kingdom—Secretary of State for Education and Skills and Secretary of State for Work and Pensions | Sri Lanka—Speaker, Parliament"
- "Urgent Debates Declined | Allegations—Hon David Benson-Pope"
- "Urgent Debates Declined | Auckland International Airport—Canada Pension Plan Investment Board Bid"
- "Urgent Debates Declined | Cabinet Documents—Telecom New Zealand"
- "Urgent Debates Declined | Capital and Coast District Health Board—Governance Changes"
- "Urgent Debates Declined | Capital and Coast District Health Board—Maternity Services"
- "Urgent Debates Declined | Capital and Coast District Health Board—State of Health Services"
- "Urgent Debates Declined | Conservation, Minister—Whangamata Marina Decision"
- "Urgent Debates Declined | Dioxin Release, Ivon Watkins-Dow—Report"
- "Urgent Debates Declined | Draft Energy Strategy—Release"
- "Urgent Debates Declined | Election Advertising—Auditor-General’s Report and Speaker’s Response"
- "Urgent Debates Declined | Election Expenses—Decision on Prosecution"
- "Urgent Debates Declined | Human Rights—United Nations Special Rapporteur’s Report"
- "Urgent Debates Declined | Laboratory Services—District Health Boards"
- "Urgent Debates Declined | Lebanon—Recent Developments"
- "Urgent Debates Declined | Police—Pepper Spray"
- "Urgent Debates Declined | Potential Terrorist Activity—Leaked Police Evidence"
- "Urgent Debates Declined | Principal Family Court Judge—Comments on Family Violence"
- "Urgent Debates Declined | Prisoner Transportation—Ombudsmen’s Report"
- "Urgent Debates Declined | Stadium—Proposed Location, Auckland"
- "Urgent Debates Declined | Terrorism Suppression Act—Solicitor-General’s Decision"
- "Urgent Debates Declined | Tranz Rail Shares—Insider Trading"
- "Urgent Debates Declined | Wanganui—Gang-related Tensions"
- "Urgent Debates Declined | Well Child Freephone Service—Contract"
- "Urgent Debates | Commission of Inquiry into Police Conduct—Report"
- "Urgent Debates | Corrections, Department—Ombudsmen’s Report"
- "Urgent Debates | Corrections, Department—Reports on Graeme Burton"
- "Urgent Debates | David Parker—Resignation from Executive"
- "Urgent Debates | Emissions Trading Scheme—Government Announcement"
- "Urgent Debates | Environment, Ministry—State Services Commission Briefing"
- "Urgent Debates | Hawke’s Bay District Health Board—Appointment of Commissioner"
- "Urgent Debates | Hawke’s Bay District Health Board—Conflicts of Interest Report"
- "Urgent Debates | Mercury Energy—Disconnection of Electricity Supply"
- "Urgent Debates | Power Outage—Upper North Island"
- "Urgent Debates | Release of Report—Telecommunications Stocktake Review"
- "Urgent Debates | Setchell Inquiry—Report to State Services Commissioner"
- "Urgent Debates | Taito Phillip Field—Report of Dr Noel Ingram QC"
- "Urgent Debates | Te W\xC4\x81nanga o Aotearoa—Auditor-General’s Report"
- "Urgent Debates | Tranz Rail Shares—Insider Trading"
- "Visitors | Australia—Attorney-General"
- "Visitors | Australia—Australian Political Exchange 2006"
- "Visitors | Australia—Bilateral Parliamentary Delegation, Parliament of Australia"
- "Visitors | Australia—Joint Standing Committee on Migration, Commonwealth of Australia"
- "Visitors | Australia—President of the Australian Federal Senate"
- "Visitors | Australia—President of the Senate"
- "Visitors | Australia—Senate Standing Committee on Community Affairs, Commonwealth Parliament"
- "Visitors | Bougainville, Autonomous Region—Speaker of the House of Representatives"
- "Visitors | Co-operative Republic of Guyana—Minister of Amerindian Affairs"
- "Visitors | Commonwealth Parliamentary Association—Secretary-General"
- "Visitors | European Parliament—Delegation"
- "Visitors | France—Vice-President, National Assembly"
- "Visitors | Germany, Federal Republic—German - Australia / New Zealand Parliamentary Friendship Group"
- "Visitors | Germany—Committee for Labour and Social Services, Bundestag"
- "Visitors | India—Chhattisgarh Legislative Assembly Delegation"
- "Visitors | India—Parliamentary Delegation, Legislative Assembly of Madhya Pradesh"
- "Visitors | Korea—Parliamentary Delegation, National Assembly"
- "Visitors | Latvia—Speaker of the Parliament, and Delegation"
- "Visitors | Mongolia—Chairman of the State Great Hural"
- "Visitors | Niue—Speaker of the Legislative Assembly"
- "Visitors | Pakistan—National Assembly and Senate"
- "Visitors | People’s Republic of China—Education, Science, Culture and Public Health Committee, National People’s Congress"
- "Visitors | People’s Republic of China—Internal and Judicial Affairs Committee, National People’s Congress"
- "Visitors | Republic of Ireland—D\xC3\xA1il \xC3\x89ireann, Working Group of Committee Chairs and the Committee of Members’ Interests"
- "Visitors | Republic of Poland—Speaker and Deputy Speaker; Speaker’s Delegation"
- "Visitors | Republic of South Africa—Deputy President"
- "Visitors | Republic of South Africa—Parliamentary Delegation"
- "Visitors | Russia—State Duma of Federal Assembly"
- "Visitors | Samoa—Speaker of the Legislative Assembly"
- "Visitors | Scottish Parliament—Minister of Parliamentary Business"
- "Visitors | South Australia—Minister for the River Murray and for Small Business"
- "Visitors | South Australia—Minister of Health"
- "Visitors | Sri Lanka—Delegation"
- "Visitors | Turkey—Grand National Assembly of Turkey"
- "Visitors | United Arab Emirates—Minister of Foreign Trade"
- "Visitors | United Kingdom—Commonwealth Parliamentary Association"
- "Visitors | United Kingdom—Deputy Speaker, House of Commons"
- "Visitors | United Kingdom—Work and Pensions Select Committee, House of Commons"
- "Visitors | Vanuatu—Deputy Prime Minister"
- Voting | Correction
- "Voting | Point of Order—Mauao Historic Reserve Vesting Bill"
- "Voting | Point of Order—Mauao Historic Reserves Vesting Bill"
- "Wine-box Inquiry—Legal Fees | Government Motion No. 1—28 March 2006"

=end

=begin
Debate::remove_duplicates(SubDebate.find(:all)).sort{|d,e| d.parent.name.downcase<=>e.parent.name.downcase}.delete_if{|s| s.about.is_a?Bill}.in_groups_by{|s| s.parent.name.downcase}.sort_by(&:size).each {|ds| puts ds[0].parent.name + ' ' + ds.size.to_s} ;nil

Wine-box Inquiry—Legal Fees 1
Rayed Mohammed Abdullah Ali—Expulsion 1
United Kingdom—Secretary of State for Education and Skills and Secretary of State for Work and Pensions 1
Australia - New Zealand Political Exchange—Members 1
Reserve Bank of New Zealand Amendment Bill, Racing Amendment Bill 1
Biosecurity Amendment Bill (No 4), Hazardous Substances and New Organisms Amendment Bill (No 2) 1
Tibet—Protests 1
Telecommunications Amendment Bill (No 2), Radiocommunications Amendment Bill (No 2) 1
Conduct in the House—Standards 1
Corrections (Social Assistance) Amendment Bill, Customs and Excise (Social Assistance) Amendment Bill, Injury Prevention, Rehabilitation, and Compensation (Social Assistance) Amendment Bill 1
Taxation (Savings Investment and Miscellaneous Provisions) Bill, Taxation (Annual Rates of Income Tax 2006-07) Bill 1
Disabled Persons Employment Promotion Repeal Bill, Minimum Wage Amendment Bill 1
Driving-related Deaths—Potential Government Reaction 1
Election Petition 1
Responses 1
Taito Phillip Field—Referral of Ingram Report to Privileges Committee 1
PlunketLine—Support 1
Government Business—Procedure 1
Housing—Replies to Questions 1
Parliamentary Press Gallery—Access to Parliamentary Complex 1
Personal Reflections and Unparliamentary Language—Principles for Intervention 1
Select Committees—Official Business 1
Intelligence and Security Committee 1
Limited Partnerships Bill, Taxation (Limited Partnerships) Bill 1
Medal Ceremony—Notification 1
Standards Amendment Bill, Testing Laboratory Registration Amendment Bill 1
Motion of No Confidence—Leave to Move 1
Speaker’s statement 1
Report—Rt Hon Winston Peters and Accusations Against Iraqis 1
India—Parliamentary Delegation, Haryana State Legislative Assembly 1
Ombudsman’s Report—Investigation into Criminal Justice Sector 2
Signage in the Chamber—New Zealand Labour Party 2
New Zealand Superannuation and Retirement Income Amendment Bill, War Pensions Amendment Bill 2
Insolvency Bill, Companies Amendment Bill, Insolvency (Cross-border) Bill 2

Inquiry 2

Supplementary Estimates 2 # link to Appropriation (2006/07 Supplementary Estimates) Bill and the Imprest Supply (First for 2007/08) Bill?

Taxation (Annual Rates of income Tax 2005-06) Bill, Taxation (Urgent Measures) Bill, Student Loan Scheme Amendment Bill 2
Aviation Crimes Amendment Bill, Civil Aviation Amendment Bill (No 2) 2
Weathertight Homes Resolution Services (Remedies) Amendment Bill, Building (Consent Authorities) Amendment Bill 2

Parliamentary Service Commission 3
Adjournment 4

Budget Statement 4 # should be linked to appropriate Appropriations Estimates Bill

Debate on Crown Entities, Public Organisations, and State Enterprises 4
Taxation (Annual Rates of Income Tax 2007-08) Bill, Taxation (Business Taxation and Remedial Matters) Bill, Taxation (KiwiSaver) Bill 4

Financial Review Debate 4 # should be linked to Appropriation Financial Review Bill OR split in to ministerial portfolio subdebates?

Electoral Finance Bill, Broadcasting Amendment Bill (No 3), Electoral Amendment Bill 4

Estimates Debate 5 # should be linked to appropriate Appropriation Estimates Bill

Ministerial Statements 5

Business of Select Committees 6 # should be linked to committee

Resignations 7
Speaker’s Statements 8

Voting 11 # should be linked to bill

Privilege 11
Urgent Debates 16
Appointments 16
Personal Explanations 17
Motions 23

Amended answers to Oral Questions 23  # should be linked to question about http://theyworkforyou.co.nz/debates/2008/mar/18/21

Speaker’s Rulings 24
Obituaries 25
Tabling of Documents 25
Urgent Debates Declined 28
Visitors 39
Points of Order 98
=end
