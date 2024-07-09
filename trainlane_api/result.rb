# frozen_string_literal: true

require 'json'

module TrainlaneApi
  class Result
    def initialize(json)
      @json = JSON.parse(json)
    end

    def journey_search
      json['journeySearch']
    end

    def journeys
      journey_search['journeys']
    end

    def fetch_journey_by_id(id)
      journeys[id]
    end

    def alternatives
      journey_search['alternatives']
    end

    def fetch_alternative_by_id(id)
      alternatives[id]
    end

    def fares
      journey_search['fares']
    end

    def fetch_fare_by_id(id)
      fares[id]
    end

    def sections
      journey_search['sections']
    end

    def fetch_section_by_id(id)
      sections[id]
    end

    def legs
      journey_search['legs'].values
    end

    def fetch_leg_by_id(id)
      journey_search['legs'][id]
    end

    def locations
      json['locations']
    end

    def fetch_location_by_id(id)
      locations[id]
    end

    def transport_modes
      json['transportModes']
    end

    def fetch_transport_mode_by_id(id)
      transport_modes[id]
    end

    def carriers
      json['carriers']
    end

    def fetch_carrier_by_id(id)
      carriers[id]
    end

    def fare_types
      json['fareTypes']
    end

    private

    attr_reader :json
  end
end