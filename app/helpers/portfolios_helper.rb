module PortfoliosHelper

	def activity_sparkline_tag(portfolio)
		%Q[<img src="portfolios/#{portfolio.url}/activity_sparkline.png" class="sparkline" alt="Sparkline graph of #{portfolio.portfolio_name} portfolio activity" />]
	end

end
