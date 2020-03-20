require 'httparty'
require 'pp'

class Slack
  include HTTParty
  base_uri 'https://slack.com/api'

  attr_accessor :verbose

  def initialize(api_token)
    @api_token = api_token
  end

  def _get(url, query)
    results = self.class.get url, query: query.merge({ token: @api_token })

    if @verbose
      pp results
    end

    results
  end

  # https://slack.com/api/conversations.list
  def conversations
    _get '/conversations.list', { limit: 1000}
  end
end
