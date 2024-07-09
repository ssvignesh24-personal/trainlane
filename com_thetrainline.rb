# frozen_string_literal: true

require_relative './models/models'
require_relative './services/journey_service'
require './trainline_api/search'

class ComThetrainline
  class << self
    def find(from, to, depart_at)
      raise 'Invalid date' unless depart_at.is_a?(DateTime)

      result = TrainlineApi::Search.call(from, to, depart_at.strftime('%FT%T'))
      journeys = result.journeys.map do |journey_id, _|
        JourneyService.call(journey_id, result)
      end
      render_results(journeys)
    end

    private

    def render_results(journeys)
      journeys
        .flatten
        .compact
        .map { |j| j.build_journey.as_json }
        .sort { |j, n| [j[:departure_at], j[:service_agencies].size] <=> [n[:departure_at], n[:service_agencies].size] }
    end
  end
end