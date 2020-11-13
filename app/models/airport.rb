module Models
  class Airport < Sequel::Model(DB[Sequel[:public][:airports]])
    dataset_module do
      def filter_by_geo_position(geo_position)
        filtered_airports = if (geo_position[:radius].nil?)
          select
        else
        select_append(
          Sequel.lit(
            'earth_distance(ll_to_earth("airports".coordinates[1], "airports".coordinates[0]), ll_to_earth(?, ?)) distance_to_geo_position',
            46.904732,
            15.702838
          ))
          .where(
            Sequel.lit(
              'earth_distance(ll_to_earth("airports".coordinates[1], "airports".coordinates[0]), ll_to_earth(?, ?)) < (?)',
              geo_position[:latitude],
              geo_position[:longitude],
              geo_position[:radius]
            )
          )
        end
        filtered_airports.all
      end
    end
  end
end

