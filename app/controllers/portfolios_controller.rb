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
  end

  def activity_sparkline
    logger.info('request.request_uri: ' + request.request_uri)
    counts = Portfolio::questions_asked_count_by_month params['portfolio_url']
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
    debates = Debate::remove_duplicates(@portfolio.oral_answers).sort_by(&:date)
    @debates_size = debates.size

    if @debates_size > 10
      latest_date = debates.last.date
      two_months_ago = (latest_date.to_time.at_beginning_of_month - 1).beginning_of_month.to_date
      newer_debates = debates.select { |d| d.date >= two_months_ago }
      older_debates = debates.select { |d| d.date < two_months_ago }
      @debates_by_name, @names = Debate::get_debates_by_name newer_debates
      @older_debates_by_name, @older_names = Debate::get_debates_by_name older_debates

    elsif @debates_size > 0
      @debates_by_name, @names = Debate::get_debates_by_name debates
      @older_debates_by_name, @older_names = [], []
    end
  end

  private

end
