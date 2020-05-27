# frozen_string_literal: true

require './config/environment'
require 'hanami/middleware/body_parser'

use Hanami::Middleware::BodyParser, :json

run AirportsAPI.new
