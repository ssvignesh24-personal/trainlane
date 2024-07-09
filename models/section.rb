# frozen_string_literal: true

class Section
  FLEXIBILITIES = %w{nonflexi semiflexi flexi}.freeze

  def initialize(id)
    @id = id
    @alternatives = []
  end

  def available_classes
    @available_classes ||= alternatives.map(&:class_name).uniq
  end

  def available_flexibilities
    @available_flexibilities ||= alternatives.map(&:flexibility).uniq
  end

  def has_standard_class?
    available_classes.include?('Standard')
  end

  def has_first_class?
    available_classes.include?('First')
  end

  def modes
    @modes ||= alternatives.map(&:mode).uniq
  end

  def price_of(class_name, flexibility)
    price = nil
    class_search_order(class_name).find do |possible_class|
      flexibility_search_order(flexibility).find do |possible_flexibility|
        selected_alternative = alternatives.find do |alternative|
          possible_class = 'Standard' if alternative.mode == 'bus' # Buses does not have first class
          alternative.class_name == possible_class && alternative.flexibility == possible_flexibility
        end
        price = selected_alternative.price unless selected_alternative.nil?
        selected_alternative
      end
    end
    price.to_f
  end

  def currency
    @currency ||= alternatives.first&.currency
  end

  def name_of(class_name, flexibility)
    alternatives.find do |alternative|
      alternative.class_name == class_name && alternative.flexibility == flexibility
    end&.name
  end

  attr_accessor :id, :alternatives

  private

  def flexibility_search_order(searching_flexibility)
    return FLEXIBILITIES.reverse if searching_flexibility == 'flexi'

    FLEXIBILITIES.rotate(FLEXIBILITIES.index(searching_flexibility))
  end

  def class_search_order(searching_class)
    return %w[First Standard] if searching_class == 'First'

    ['Standard']
  end
end
