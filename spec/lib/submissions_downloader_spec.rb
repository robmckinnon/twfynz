require File.dirname(__FILE__) + '/../spec_helper'

describe SubmissionsDownloader do

  def H html; Hpricot html; end

  def example_doc; H("<html><table>#{@submission}#{@submission}</table></html>"); end
  def example_details; H("<html><table>#{@detail}#{@detail}</table></html>"); end

  before :all do
    @committee = 'Commerce Committee'
    @date_text = '27 Mar 08'
    @submission = %Q|<tr>
      <td>
        <h4><a id="_ctl0__ctl0_MainContent__ctl1_rptRecords__ctl1_lnkTitle" href="/en-NZ/SC/Papers/Evidence/4/8/4/48SCCOSCEvidencefA3178_A7138-Economic-analysis-of-energy-efficiency.htm">Economic analysis of energy efficiency in commercial buildings</a></h4>
        <p>2006/07 financial review of Electricity Commission</p>
      </td>
        <td class="attr attrauthor">#{@committee}</td>
      <td class="attr attrPublicationDate">#{@date_text}</td>
    </tr>|
    @view_all_url = '/CmsSystem/Templates/Documents/DetailedListing.aspx?NRNODEGUID=%7b4D6BDF90-D216-4F58-B207-7D2F3DF4171F%7d&amp;p=1'
    @view_all = %Q|<a rel="nofollow" href="#{@view_all_url}" title="View the contents of these documents on one page">View details</a>|

    @buiness_item = 'Electricity Industry Reform Amendment Bill'
    @submitter_text = 'Genesis Energy Supp1'
    @title_text = "#{@buiness_item} – #{@submitter_text}"
    @title = "<h1>#{@title_text}</h1>"
    @genesis_doc_ = '/NR/rdonlyres/C17F8408-A4E8-4133-9937-FA78EBA3D2B3/82589/GenesisEnergySupp1_.pdf'
    @genesis_doc_1 = '/NR/rdonlyres/C17F8408-A4E8-4133-9937-FA78EBA3D2B3/82589/GenesisEnergySupp1_1.pdf'

    @documents = %Q|<li>
          <a href="#{@genesis_doc_}"></a>
          <a href="#{@genesis_doc_1}"><cite>Full evidence text</cite> [PDF 484k]</a>
        </li>|

    @no_documents = %Q|<div class="section"><h1>ME</h1></div>
    <div class="hide"></div>
    <li>
      <a href="MeridianEnergy.pdf"></a>
      <a href="MeridianEnergy.pdf" target="_blank">Full evidence text</a>
    </li>|

    @detail = %Q|<tr><td>
        <div class="section">
          #{@title}
          <p>You can get this document in PDF format from the ‘Downloads’&nbsp; panel.</p>
        </div>
        <div class="hide">
          <ul class=""><li>item-reference-fA4199</li><li>evidence-fA4199</li></ul>
        </div>
        #{@documents}
      </td></tr>|

  end

  it 'should find submitter name' do
    SubmissionsDownloader.submitter_search_term('Genesis Energy').should == 'Genesis%20Energy'
    SubmissionsDownloader.submitter_search_term('Genesis Energy Supp1').should == 'Genesis%20Energy'
    SubmissionsDownloader.submitter_search_term('Genesis Energy supp2').should == 'Genesis%20Energy'
  end

  it 'should find feeling lucky url' do
    site = 'http://www.genesisenergy.co.nz/'
    name = 'Genesis Energy'
    search_result = %Q|<h2 class=r><a href="#{site}" class=l onmousedown="return clk(this.href,'','','res','1','')"><b>#{name}</b> Home Page</a></h2>|

    SubmissionsDownloader.should_receive(:search_results).with(name).and_return H(search_result)
    SubmissionsDownloader.feeling_lucky_url(name).should == site
  end

  it 'should find submission title elements' do
    elements = SubmissionsDownloader.find_title_elements example_details
    elements.size.should == 2
    elements.first.inner_text.should == @title_text
  end

  it 'should find business item name' do
    business_item = SubmissionsDownloader.find_business_item H(@title)
    business_item.should == @buiness_item
  end

  it 'should find documents submitted' do
    title_element = H(@detail).at('h1')
    document = SubmissionsDownloader.find_document title_element
    document.should == @genesis_doc_1
  end

  it 'should find documents submitted' do
    title_element = H(@no_documents).at('h1')
    document = SubmissionsDownloader.find_document title_element
    document.should be_nil
  end

  it 'should find submitter text' do
    submitter = SubmissionsDownloader.find_submitter_text H(@title)
    submitter.should == @submitter_text
  end

  it 'should find view all url' do
    SubmissionsDownloader.find_view_all_url(H(@view_all)).should == @view_all_url.sub('&amp;','&')
  end

  it 'should find dates' do
    dates = SubmissionsDownloader.find_dates example_doc
    dates.size.should == 2
    dates.first.should == '2008-03-27'
  end

  it 'should find committees' do
    committees = SubmissionsDownloader.find_committees example_doc
    committees.size.should == 2
    committees.first.should == @committee
  end

  it 'should return false if there are no submissions on page' do
    SubmissionsDownloader.stub!(:open_page).and_return
    SubmissionsDownloader.stub!(:find_committees).and_return []
    SubmissionsDownloader.should_not_receive(:create_submissions)
    SubmissionsDownloader.download_page(1).should == false
  end

  it 'should return true if there are submissions on page' do
    doc = mock('doc')
    committees = [mock('committee')]

    SubmissionsDownloader.stub!(:open_page).and_return doc
    SubmissionsDownloader.stub!(:find_committees).and_return committees
    SubmissionsDownloader.should_receive(:create_submissions).with(committees, doc)
    SubmissionsDownloader.download_page(1).should == true
  end
end
