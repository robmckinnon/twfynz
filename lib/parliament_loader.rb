require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'

module ParliamentLoader

  def self.add_48th_parliament
    parliament = Parliament.new :ordinal => '48th',
      :commission_opening_date => '2005-11-07',
      :commission_opening_debate_id => Debate.find(:first, :conditions => 'name = "Commission Opening of Parliament" and year(date) = 2005').id,
      :dissolution_date => '2008-10-03',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament'

    parliament.id = 48
    parliament.save
  end

  def self.add_49th_parliament
    parliament = Parliament.new :ordinal => '49th',
      :commission_opening_date => nil,
      # :commission_opening_debate_id => Debate.find(:first, :conditions => 'name = "Commission Opening of Parliament" and year(date) = 2005').id,
      :dissolution_date => nil,
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament'

    parliament.id = 49
    parliament.save
  end


  def self.add_49th_parliament_parties
    ParliamentParty.create :parliament_id => 49,
      :party_id => 1,
      :parliament_description => %Q|<p>ACT New Zealand has five members of Parliament, led in Parliament by John Boscawen. The party has a confidence and supply arrangement with the National-led government.</p>|,
      :in_parliament_text => %Q|<p>ACT New Zealand first registered with the Electoral Commission in February 1995 and entered Parliament in 1996. The Hon Rodney Hide is a Minister outside Cabinet in the National-led government.</p>
<p>The party is currently represented in Parliament by five members — one represents an electorate, Epsom, and four are drawn from the party list.</p>|,
      :parliament_agreements_text => '<p>“ACT agrees to provide confidence and supply, for the term of this Parliament, to a National-led government.”</p>
<p>Source: <cite>National-ACT, Confidence and Supply Agreement</cite>, 16 November 2008</p>',
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/5634F13B-7744-4D03-A9F9-EBB0E4F83621/191481/NationalAct_Agreement20098.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/ACTNZ/e/9/d/00PlibMPPACTNZ1-ACT-New-Zealand.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#ACT_New_Zealand_.285.29'

    ParliamentParty.create :parliament_id => 49,
      :party_id => 2,
      :parliament_description => %Q|<p>The Green Party of Aotearoa / New Zealand (Green Party) is an Opposition party. The Green Party has nine members of Parliament in the House all elected from the party list.</p>|,
      :in_parliament_text => %Q|<p>The Greens, The Green Party of Aotearoa / New Zealand first registered with the Electoral Commission in August 1995 and entered Parliament in 1995. The party has not been in Government.</p>
<p>The Green Party has nine members in the 49th Parliament, all elected from the party list.</p>
<p>The party is led by co-leaders, Metiria Turei and Russel Norman.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Green/c/4/7/00PlibMPPGreen1-Green-Party.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#Green_Party_of_Aotearoa_New_Zealand_.289.29'

    ParliamentParty.create :parliament_id => 49,
      :party_id => 3,
      :parliament_description => %Q|<p>The New Zealand Labour Party (Labour Party) has 42 members of Parliament, led by Hon Phil Goff. The party is in opposition.</p>|,
      :in_parliament_text => %Q|<p>The New Zealand Labour Party was established in 1916 and first entered Parliament in 1919. The party has been in five Governments: 1935-1949, 1957-1960, 1972-1975, 1984-1990, and 1999-2008.</p>
<p>The party is represented by 42 members in the 49th Parliament — 20 represent electorates and 22 are drawn from the party list.</p>
<p>The party leader is Hon Phil Goff, member for Mt Roskill.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Labour/2/4/2/00PlibMPPLabour1-Labour-Party.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#New_Zealand_Labour_Party_.2842.29'

    ParliamentParty.create :parliament_id => 49,
      :party_id => 4,
      :parliament_description => %Q|<p>The Māori Party has four members of Parliament. It has a confidence and supply arrangement with the National-led government.</p>|,
      :in_parliament_text => %Q|<p>The Māori Party registered with Electoral Commission in July 2004 and first entered Parliament the same year on a by-election. The Hon Tariana Turia and Hon Dr Pita Sharples are Ministers outside Cabinet in the National-led government from November 2008.</p>
<p>The party is currently represented in Parliament by four members; all representing Māori electorates. The current party co-leaders are Hon Tariana Turia and Hon Dr Pita Sharples.</p>|,
      :parliament_agreements_text => '<p>“The Maori Party agrees to provide confidence and supply for the term of this Parliament to a National Party-led Government.”</p>
<p> Source: <cite>Relationship and Confidence and Supply Agreement between the National Party and the Maori Party</cite>, 16 November 2008 </p>',
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/22CACF7A-2530-45E6-9569-518E53CF0056/184002/NationalMaori_Party_agreement20096.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Maori/6/6/a/00PlibMPPMaori1-M-ori-Party.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#M.C4.81ori_Party_.284.29'

   ParliamentParty.create :parliament_id => 49,
      :party_id => 5,
      :parliament_description => %Q|<p>The New Zealand National Party (National Party) is the largest partner in the National-led Government. It has 58 members of Parliament in the House of which 41 represent electorates.</p>|,
      :in_parliament_text => %Q|<p>The New Zealand National Party was established in 1936 from the Reform-United Coalition. The party first entered Parliament that same year.</p>
<p>The party has been in five Governments: 1949–1957, 1960–1972, 1975–1984, 1990–1999, and 2008-</p>
<p>The National Party has 58 members of Parliament — 41 representing general electorates and 18 drawn from the party list.</p>
<p>The current party leader is the Hon John Key, Prime Minister and member for Helensville.</p>|,
      :parliament_agreements_text => '<p>The New Zealand National Party is the principal partner in the National-led Government.</p>
<p>The National Party has the following agreements with other parliamentary parties:</p>
<ul>
<li>A confidence and supply agreement with ACT</li>
<li>A confidence and supply agreement with the Maori Party</li>
<li>A confidence and supply agreement with United Future</li></ul>',
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/National/b/b/b/00PlibMPPNational1-National-Party.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#New_Zealand_National_Party_.2858.29'

    ParliamentParty.create :parliament_id => 49,
      :party_id => 7,
      :parliament_description => %Q|<p>Jim Anderton’s Progressive (Progressive) has one member of Parliament. It is an opposition party.</p>|,
      :in_parliament_text => %Q|<p>Jim Anderton’s Progressive formed in 2002 from part of the former Alliance Party. The party registered with the Electoral Commission in June 2002 and first entered Parliament that same year.</p>
<p>Progressive was in coalition with two Labour-led governments from its inception in 2002 until November 2008.</p>
<p>The party is led and represented in Parliament by the Hon Jim Anderton, member for Wigram.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Progressive/0/8/a/00PlibMPPProgressive1-Progressive.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#Jim_Anderton.27s_Progressive_Party_.281.29'

    ParliamentParty.create :parliament_id => 49,
      :party_id => 8,
      :parliament_description => %Q|<p>United Future New Zealand (United Future) has one member of Parliament. It has a confidence and supply agreement with the National-led government.</p>|,
      :in_parliament_text => %Q|<p>United Future formed in 2000 after a merger of Future New Zealand (formerly the Christian Democrats) and the United Party. The party registered with the Electoral Commission in December 2001 and first entered Parliament that same year.</p>
<p>The party is currently represented in Parliament by one member, the Hon Peter Dunne, who is the member for Ohariu. He is a Minister outside of Cabinet in the National-led government from November 2008. Unted Future previously had a confidence and supply agreement with the Labour-Progressive Coalition Government from 2005-2008.</p>|,
      :parliament_agreements_text => %Q|<p>’United Future agrees to provide confidence and supply through positive votes of support for the term of this Parliament to a National-led government.’</p>
<p>Source: United Future, <cite>Confidence and Supply Agreement with United Future</cite>, 16 November 2008</p>|,
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/5E74E888-B2FF-4663-906D-C551BE4E252D/94921/NationalUF_agreement20092.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/UnitedFuture/7/b/9/00PlibMPPUnitedFuture1-United-Future.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/49th_New_Zealand_Parliament#United_Future_New_Zealand_.281.29'
  end

  def self.add_48th_parliament_parties
    ParliamentParty.create :parliament_id => 48,
      :party_id => 1,
      :parliament_description => %Q|<p>ACT New Zealand is an Opposition party with two members of Parliament.</p>|,
      :in_parliament_text => %Q|<p>ACT New Zealand first registered with the Electoral Commission in February 1995 and entered Parliament in 1996. The party has not been in Government.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/ACTNZ/e/9/d/e9dd6c709c8c4cd5923a05826d775f57.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#ACT_New_Zealand_.282.29'

    ParliamentParty.create :parliament_id => 48,
      :party_id => 2,
      :parliament_description => %Q|<p>The Green Party of Aotearoa / New Zealand (Green Party) is an Opposition party with a co-operation agreement with the Government. The Green Party has six members of Parliament in the House all elected from the party list.</p>|,
      :in_parliament_text => %Q|<p>The Greens, The Green Party of Aotearoa / New Zealand first registered with the Electoral Commission in August 1995 and entered Parliament in 1995. The party has not been in Government.</p><p>The Green Party has six members in the 48th Parliament, all elected from the party list.</p>|,
      :parliament_agreements_text => %Q|<p>’The Green Party agrees to provide stability to a Labour/Progressive coalition government by co-operating on agreed policy and budget initiatives and not opposing confidence or supply for the term of this Parliament.’</p><p>Source: Green Party,<cite> Labour-led Government Co-operation Agreement with Greens</cite>, 17 October 2005</p>|,
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/641FC3A5-3ED8-4769-AC33-C39841861AC7/36029/Green5.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Green/c/4/7/c47d14f946564ac48355e44f6d864d70.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#Green_Party_.286.29'

  ParliamentParty.create :parliament_id => 48,
      :party_id => 3,
      :parliament_description => %Q|<p>The New Zealand Labour Party (Labour Party) is the largest partner in the Labour-Progressive Coalition Government. It has 49 members of Parliament in the House of which 30 represent electorates.</p>|,
      :in_parliament_text => %Q|<p>The New Zealand Labour Party was established in 1916 and first entered Parliament in 1919. The party has been in five Governments: 1935-1949, 1957-1960, 1972-1975, 1984-1990, and 1999-present.</p><p>The party is represented by 49 members in the 48th Parliament — 30 represent electorates and 19 are drawn from the party list.</p>|,
      :parliament_agreements_text => %Q|<p>The New Zealand Labour Party is the principal partner in the Labour-Progressive Coalition Government.</p><p>The Labour Party has the following agreements with other parliamentary parties:</p>
      <ul class="">
        <li>A coalition agreement with Progressive</li>
        <li>A confidence and supply agreement with NZ First</li>
        <li>A confidence and supply agreement with United Future</li>
        <li>A co-operation agreement with the Green Party</li>
      </ul>|,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Labour/2/4/2/2429699102f54002931da5168ca4645a.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#New_Zealand_Labour_Party_.2849.29'

    ParliamentParty.create :parliament_id => 48,
      :party_id => 4,
      :parliament_description => %Q|<p>The Māori Party has four members of Parliament. The party is in Opposition.</p>|,
      :in_parliament_text => %Q|<p>The Māori Party registered with Electoral Commission in July 2004 and first entered Parliament the same year. The party has not been in Government.</p><p>The party is represented in the House by four members; all representing Māori electorates.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Maori/6/6/a/66af033c5f2f486f8bfe282f5f3ea159.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#M.C4.81ori_Party_.284.29'

   ParliamentParty.create :parliament_id => 48,
      :party_id => 5,
      :parliament_description => %Q|<p>The New Zealand National Party (National Party) has 48 members of Parliament. The party is in Opposition.</p>|,
      :in_parliament_text => %Q|<p>The New Zealand National Party was established in 1936 from the Reform-United Coalition. The party first entered Parliament that same year.</p><p>The party has been in four Governments: 1949–1957, 1960–1972, 1975–1984, and 1990–1999.</p><p>The National Party has 48 members of Parliament — 31 representing general electorates and 17 drawn from the party list.</p>|,
      :parliament_agreements_text => nil,
      :agreements_file => nil,
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/National/b/b/b/bbbb9d13d4e64d68afa75d632fbcf80f.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#New_Zealand_National_Party_.2847.29'

    ParliamentParty.create :parliament_id => 48,
      :party_id => 6,
      :parliament_description => %Q|<p>The New Zealand First Party (NZ First) has seven members of Parliament. The party has a confidence and supply agreement with the Labour-led coalition.</p>|,
      :in_parliament_text => %Q|<p>NZ First registered with the Electoral Commission in December 1994. The party first entered Parliament that same year.</p><p>NZ First has been in one Government from 1996–1998. The Rt Hon Winston Peters is a Minister outside Cabinet in the Labour-led coalition.</p><p>The party’s current seven members of Parliament are all drawn from the party list.</p>|,
      :parliament_agreements_text => %Q|<p>’New Zealand First agrees to provide confidence and supply for the term of this Parliament, to a Labour-led coalition.’</p><p>Source: <cite>New Zealand First, Confidence and Supply Agreement with New Zealand First</cite>, 17 October 2005</p>|,
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/29ABBEDB-3B9B-4EE5-9DA5-5E1646A2B264/36039/NZFirst5.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/NZFirst/8/c/1/8c16caceb4ee4ab7b43f07449e8abfb7.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#New_Zealand_First_.287.29'

    ParliamentParty.create :parliament_id => 48,
      :party_id => 7,
      :parliament_description => %Q|<p>Jim Anderton’s Progressive (Progressive) is a partner in the 2005 Coalition Government. The party has one member of Parliament, the Hon Jim Anderton.</p>|,
      :in_parliament_text => %Q|<p>Jim Anderton’s Progressive formed in 2002 from part of the former Alliance Party. The party registered with the Electoral Commission in June 2002 and first entered Parliament that same year.</p><p>Progressive has been in two Governments from 2002 to present.</p><p>The party is represented in Parliament by the Hon Jim Anderton, member for Wigram.</p>|,
      :parliament_agreements_text => %Q|<p>Progressive has a coalition agreement with the Labour Party.</p><p>’The two parties will work together in good faith and with “no surprises”, reflecting appropriate notice and consultation on important matters including the ongoing development of policy.’</p><p>Source: Progressive,<cite> Coalition Agreement: Labour and Progressive Parties in Parliament</cite>, 17 October 2005</p>|,
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/977E7FE0-09FB-49AD-AA05-36381FAAFBE9/36447/Progressives1.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/Progressive/0/8/a/08aa1370001d4476b2b159c575b06b6c.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#Progressive_Party_.281.29'

    ParliamentParty.create :parliament_id => 48,
      :party_id => 8,
      :parliament_description => %Q|<p>United Future New Zealand (United Future) has a confidence and supply agreement with the 2005 Government. It is represented in the House by one member of Parliament.</p>|,
      :in_parliament_text => %Q|<p>United Future formed in 2000 after a merger of Future New Zealand (formerly the Christian Democrats) and the United Party. The party registered with the Electoral Commission in December 2001 and first entered Parliament that same year.</p><p>The party is currently represented in Parliament by Hon Peter Dunne, member for Ohariu Belmont, who is a Minister outside Cabinet.</p>|,
      :parliament_agreements_text => %Q|<p>’United Future agrees to provide confidence and supply for the term of this Parliament, to a Labour-led government.’</p><p>Source: United Future, <cite>Confidence and Supply Agreement with United Future</cite>, 17 October 2005</p>|,
      :agreements_file => 'http://www.parliament.nz/NR/rdonlyres/5E74E888-B2FF-4663-906D-C551BE4E252D/55415/United92.pdf',
      :parliament_url => 'http://www.parliament.nz/en-NZ/MPP/Parties/UnitedFuture/7/b/9/7b90d749a9e84f9096ea1905012b4605.htm',
      :wikipedia_url => 'http://en.wikipedia.org/wiki/48th_New_Zealand_Parliament#United_Future_.282.29'
  end

end
