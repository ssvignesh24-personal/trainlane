# frozen_string_literal: true

require 'date'
require_relative 'com_thetrainline'

pp ComThetrainline.find('London', 'Manchester', DateTime.now)