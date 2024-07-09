# frozen_string_literal: true

class Alternative
  attr_accessor :price, :currency, :flexibility, :class_name, :name, :class_id, :mode

  def initialize(id)
    @id = id
  end
end
