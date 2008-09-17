require 'sparklines'

class PortfoliosController < ApplicationController

  caches_action :index, :show_portfolio
  caches_page :activity_sparkline

  layout "portfolios_layout"

  def index
    @portfolios_on = true
    @portfolios_with_debates = Portfolio.find_all_with_debates
    # @parties = Party.all_size_ordered.delete_if {|p| p.short == 'Independent'}
    # @questions_per_party = Hash.new {|h,k| h[k] = 0}
    # @portfolios_with_debates.each do |p|
      # questions = p.questions_asked_by_party
      # @parties.each do |party|
        # @questions_per_party[party] += (questions[party] ? questions[party].size : 0)
      # end
    # end
    @portfolios_with_debates = @portfolios_with_debates.group_by {|p| p.url}
    @letter_to_portfolios = @portfolios_with_debates.keys.group_by {|p| p[0..0]}
    @portfolios_without_debates = Portfolio.find_all_without_debates.group_by {|b| b.url}
=begin
    @portfolios_image_map_areas = [
      Area.new('425,106,540,122','Prime Minister'),
      Area.new('425,60,500,78','Health'),
      Area.new('160,52,235,68','Finance'),
      Area.new('150,69,235,85','Education'),
      Area.new('164,100,235,116','Justice'),
      Area.new('34,130,235,142','Social Development Employment'),
      Area.new('142,143,235,155','Immigration'),
      Area.new('142,156,235,168','Corrections'),
      Area.new('86,169,235,177','Energy'),
      Area.new('86,178,235,191','Climate Change'),
      Area.new('142,192,235,204','Housing'),
      Area.new('142,205,235,215','Police'),
      Area.new('142,216,235,228','Transport'),
      Area.new('142,229,235,239','Maori Affairs'),
      Area.new('425,198,543,213','Other Porfolios', '#portfolios')
    ]
=end
  end

  def activity_sparkline
    logger.info('request.request_uri: ' + request.request_uri)
    counts = Portfolio::questions_asked_count_by_month params['portfolio_url']
    # , :background_color => 'transparent'
    params = { :type => 'smooth', :height => (counts.max * 0.5), :step => 3, :line_color => '#333333' }

    send_data(Sparklines.plot(counts, params),
          :disposition => 'inline',
          :type => 'image/png',
          :filename => "spark_#{params[:type]}.png" )
  end

  def show_portfolio
    @portfolios_on = true
    name = params[:portfolio_url]
    @portfolio = Portfolio.find_by_url(name, :include => :oral_answers)
    @hash = params
    debates = Debate.remove_duplicates(@portfolio.oral_answers).sort_by(&:date)
    @debates_size = debates.size

    if @debates_size > 10
      latest_date = debates.last.date
      two_months_ago = (latest_date.to_time.at_beginning_of_month - 1).beginning_of_month.to_date
      newer_debates = debates.select { |d| d.date >= two_months_ago }
      older_debates = debates.select { |d| d.date < two_months_ago }
      @debates_in_groups_by_name = Debate.debates_in_groups_by_name newer_debates
      @older_debates_in_groups_by_name = Debate.debates_in_groups_by_name older_debates

    elsif @debates_size > 0
      @debates_in_groups_by_name = Debate.debates_in_groups_by_name debates
      @older_debates_in_groups_by_name = []
    end
  end

end

class Area
  attr_reader :coords, :url, :alt

  def initialize coords, name, anchor=nil
    @coords, @alt = coords, name
    @url = "http://theyworkforyou.co.nz/portfolios/#{anchor ? anchor : name.downcase.tr(' ','_')}"
  end
end
