Sequel.migration do
  up do
    create_table(:airports) do
      primary_key :id
      String :iata_code
      String :icao_code
      String :name
      String :asciiname
      Point :coordinates
      String :country_code
      String :country_name
      String :continent_name
      String :adm1_code
      String :adm1_name
      String :adm1_name_ascii
      String :adm2_code
      String :adm2_name
      String :adm2_name_ascii
      String :adm3_code
      String :adm4_code
      Integer :population
      Integer :elevation
      Integer :gtopo30
      String :timezone
      Time :gmt_offset, only_time: true
      Time :dst_offset, only_time: true
      Time :raw_offset, only_time: true
    end
  end

  down do
    drop_table(:airports)
  end

end
