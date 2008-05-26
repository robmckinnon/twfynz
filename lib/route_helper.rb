require File.dirname(__FILE__) + '/../vendor/rails/actionpack/lib/action_controller/integration'

class RouteHelper

  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  def initialize app, helper
    app = ActionController::Integration::Session.new unless app
    @app = app
  end

  def method_missing symbol, *args
    if symbol.to_s.ends_with?'url'
      @app.send(symbol, *args).sub('www.example.com','theyworkforyou.co.nz')
    end
  end

  # def evaluate symbol, *args
    # @app.send(symbol, *args).sub('www.example.com','theyworkforyou.co.nz')
  # end
end
