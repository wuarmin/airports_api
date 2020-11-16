require 'hanami/validations'
require 'dry/monads'

module Services
  class SearchAirports
    include Dry::Monads[:result]

    attr_reader :errors

    class << self; attr_reader :column_count end
    @column_count = DB[Sequel[:information_schema][:columns]].where(table_name: 'airports').count

    class ParamsValidator < Hanami::Validator
      schema do
        required(:filter).maybe(:hash) do
          optional(:geo_position).maybe(:hash) do
            required(:latitude).filled(:float)
            required(:longitude).filled(:float)
            required(:radius).maybe(:integer)
          end
          optional(:country_code).maybe(:string)
        end
        required(:order_definition).array(:hash) do
          required(:field).filled(:symbol)
          required(:sort_order).value(:symbol, included_in?: [:asc, :desc])
        end
      end

      rule(:filter, :order_definition) do
        geo_position = values[:filter][:geo_position]
        fields = values[:order_definition].map { |order_item| order_item[:field] }
        if geo_position.nil? && fields.include?(:distance_to_geo_position)
          key.failure('AirportOrderField DISTANCE_TO_GEO_POSITION is useless unless geo_position is defined')
        end
      end
    end

    def initialize
      @errors = []
    end

    def success?
      @errors.empty?
    end

    def call(params)
      validation_result = validate(params)
      if (validation_result.success?)
        set_members(validation_result)
        Success(build_search_dataset)
      else
        Failure(create_errors(validation_result.errors.to_h))
      end
    end

    private

    def validate(params)
      ParamsValidator.new.call(params)
    end

    def set_members(validation_result)
      @filter = validation_result[:filter]
      @order_definition = validation_result[:order_definition]
    end

    def build_search_dataset
      dataset
        .then { |dataset| compute_distance_to_geo_position(dataset) }
        .then { |dataset| filter_by_geo_unit(dataset) }
        .then { |dataset| filter_by_country_code(dataset) }
        .then { |dataset| order_by(dataset) }
    end

    def dataset
      DB[Sequel[:public][:airports]]
    end

    def compute_distance_to_geo_position(dataset)
      geo_position = @filter[:geo_position]
      return dataset.select_append(Sequel.lit('null distance_to_geo_position')) if geo_position.nil?

      dataset.select_append(
        Sequel.lit(
          'round(earth_distance(ll_to_earth("airports".coordinates[1], "airports".coordinates[0]), ll_to_earth(?, ?)))::int distance_to_geo_position',
          geo_position[:latitude],
          geo_position[:longitude]
        )
      )
    end

    def filter_by_geo_unit(dataset)
      radius = @filter.dig(:geo_position, :radius)
      return dataset if radius.nil?

      geo_position = @filter[:geo_position]
      dataset.where(
        Sequel.lit(
          'earth_distance(ll_to_earth("airports".coordinates[1], "airports".coordinates[0]), ll_to_earth(?, ?)) <= (?)',
          geo_position[:latitude],
          geo_position[:longitude],
          geo_position[:radius]
        )
      )
    end

    def filter_by_country_code(dataset)
      country_code = @filter[:country_code]
      return dataset if country_code.nil?

      dataset.where { |v_row| { v_row.lower(:country_code) => v_row.lower(country_code) } }
    end

    def order_by(dataset)
      @order_definition.reduce(dataset) do |dataset, order_item|
        field = order_item[:field]
        dataset.order(
          Sequel.send(order_item[:sort_order], order_field_columns[field])
        )
      end
    end

    def order_field_columns
      @order_field_columns ||= {
        id: :id,
        distance_to_geo_position: Sequel.lit("#{self.class.column_count+1}"),
        name: :name
      }
    end

    def create_errors(errors)
      flatten_hash(errors).map do |key, errors|
        if key.to_s.include?('.')
          "#{key} #{errors.join(', ')}"
        else
          errors.join(', ')
        end
      end
    end

    def flatten_hash(hash)
      hash.each_with_object({}) do |(k, v), h|
        if v.is_a? Hash
          flatten_hash(v).map do |h_k, h_v|
            h["#{k}.#{h_k}".to_sym] = h_v
          end
        else
          h[k] = v
        end
       end
    end

  end
end

