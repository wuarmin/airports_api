ENV['RACK_ENV'] ||= "development"

# globals
ENVIRONMENT = ENV['RACK_ENV']
ROOT = File.expand_path("../..", Pathname.new(__FILE__).realpath)

# bundler
require 'bundler/setup'
Bundler.require(:default, ENVIRONMENT)

# load env-variables
case ENVIRONMENT
when 'development'
  Dotenv.load("#{ROOT}/.env.development")
when 'test'
  Dotenv.load("#{ROOT}/.env.test")
when 'production'
  Dotenv.load("#{ROOT}/.env")
end

# database
DB = Sequel.connect(ENV['DATABASE_URL'], :loggers => [Logger.new($stdout)])

# require code
Hanami::Utils.require!("#{ROOT}/app")
require './airports_api'
