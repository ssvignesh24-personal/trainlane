# frozen_string_literal: true

require 'json'
require_relative 'result'

module TrainlineApi
  class Search
    def initialize(from, to, depart_at)
      @from = from
      @to = to
      @depart_at = depart_at
    end

    def self.call(from, to, depart_at)
      new(from, to, depart_at).result
    end

    def response_json
      # Mocking the API response
      path = File.join(File.dirname(__FILE__), 'sample_response.json')
      File.read(path)
    end

    def result
      TrainlineApi::Result.new(response_json)
    end
  end
end
