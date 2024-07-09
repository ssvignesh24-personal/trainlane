# frozen_string_literal: true

require 'set'

class JourneyService
  class << self
    def call(id, result)
      journey_json = result.fetch_journey_by_id(id)
      return unless journey_json['sections'].any?

      new(id, result)
    end
  end

  def initialize(id, result)
    @id = id
    @result = result
  end

  def build_journey
    journey_json = result.fetch_journey_by_id(id)
    create_journey(journey_json)
  end

  private

  attr_reader :id, :result

  def create_journey(journey_json)
    Journey.new(id).tap do |journey|
      journey.sections = journey_json['sections'].map { |section_id| create_section(section_id) }.compact
      journey.depart_at_str = journey_json['departAt']
      journey.arrive_at_str = journey_json['arriveAt']
      journey.departure_location = departure_location(journey_json)
      journey.arrival_location = arrival_location(journey_json)
      journey.changeovers = journey_json['legs'].size - 1
      journey.service_agencies = identify_service_agencies(journey_json)
    end
  end

  def create_section(section_id)
    section_json = result.fetch_section_by_id(section_id)
    return unless section_json

    Section.new(section_id).tap do |section|
      section.alternatives = section_json['alternatives'].map do |alternative_id|
        alternative_json = result.fetch_alternative_by_id(alternative_id)
        next unless alternative_json

        create_alternative(alternative_json)
      end.compact
    end
  end

  def departure_location(journey_json)
    first_leg = result.fetch_leg_by_id(journey_json['legs'].first)
    result.fetch_location_by_id(first_leg['departureLocation'])['name']
  end

  def arrival_location(journey_json)
    last_leg = result.fetch_leg_by_id(journey_json['legs'].last)
    result.fetch_location_by_id(last_leg['arrivalLocation'])['name']
  end

  def identify_service_agencies(journey_json)
    carriers = Set.new
    journey_json['legs'].map do |leg_id|
      carrier_id = result.fetch_leg_by_id(leg_id)['carrier']
      carriers.add(result.fetch_carrier_by_id(carrier_id)['name'])
    end
    carriers
  end

  def create_alternative(alternative_json)
    fare_id = alternative_json['fares'].last
    fare_json = result.fetch_fare_by_id(fare_id)
    transport_mode_id = result.fetch_leg_by_id(fare_json.dig('fareLegs', 0, 'legId'))['transportMode']
    build_alternative(alternative_json, fare_json, transport_mode_id)
  end

  def build_alternative(alternative_json, fare_json, transport_mode_id)
    Alternative.new(alternative_json['id']).tap do |alternative| 
      alternative.price = alternative_json.dig('price', 'amount')
      alternative.currency = alternative_json.dig('price', 'currencyCode')
      alternative.flexibility = alternative_json.dig('flexibility', 'name')
      alternative.class_name = fare_json.dig('fareLegs', 0, 'travelClass', 'name')
      alternative.class_id = fare_json.dig('fareLegs', 0, 'travelClass', 'id')
      alternative.name = fare_json.dig('fareLegs', 0, 'comfort', 'name')
      alternative.mode = result.fetch_transport_mode_by_id(transport_mode_id)['mode']
    end
  end
end