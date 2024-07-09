# frozen_string_literal: true

require 'date'

class Journey
  attr_accessor :sections, :depart_at_str, :arrive_at_str, :departure_location,
                :arrival_location, :changeovers, :service_agencies

  def initialize(id)
    @id = id
    @sections = []
  end

  def available_classes
    return @available_classes if @available_classes

    @available_classes = []
    @available_classes << 'Standard' if sections.all?(&:has_standard_class?)
    @available_classes << 'First' if sections.any?(&:has_first_class?)
    @available_classes
  end

  def available_flexibilities
    @available_flexibilities ||= sections.flat_map(&:available_flexibilities).uniq
  end

  def as_json
    {
      departure_station: departure_location,
      departure_at: depart_at_utc,
      arrival_station: arrival_location,
      arrival_at: arrive_at_utc,
      service_agencies: service_agencies.to_a,
      duration_in_minutes: ((arrive_at_utc.to_time - depart_at_utc.to_time) / 60).to_i,
      changeovers:,
      products: modes,
      fares: fare_json
    }
  end

  private

  def build_fare_json(class_name, flexibility)
    name = sections.first.name_of(class_name, flexibility)
    return if name.nil?

    currency = sections.first.currency
    price = sections.sum do |section|
      section.price_of(class_name, flexibility)
    end.round(2) * 100
    {
      name:, price_in_cents: price.to_i, currency:, comfort_class: comfort_class(class_name)
    }
  end

  def modes
    @modes ||= sections.flat_map(&:modes).uniq
  end

  def comfort_class(class_name)
    class_name

    # class_name == 'First' ? '1' : '2'
  end

  def fare_json
    fares = []
    available_classes.each do |class_name|
      available_flexibilities.each do |flexibility|
        fares << build_fare_json(class_name, flexibility)
      end
    end
    fares.compact
  end

  def depart_at_utc
    DateTime.parse(depart_at_str).new_offset(0)
  end

  def arrive_at_utc
    DateTime.parse(arrive_at_str).new_offset(0)
  end
end