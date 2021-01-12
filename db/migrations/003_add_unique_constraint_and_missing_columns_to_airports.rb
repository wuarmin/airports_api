Sequel.migration do
  up do
    alter_table(:airports) do
      add_unique_constraint [:iata_code, :icao_code], name: :iata_code_icao_code_ukey
      add_column :first_loaded, DateTime
      add_column :last_loaded, DateTime
    end
  end

  down do
    alter_table(:airports) do
      drop_constraint(:iata_code_icao_code_ukey)
      drop_column :first_loaded
      drop_column :last_loaded
    end
  end
end
