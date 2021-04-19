Sequel.migration do
  up do
    run "CREATE EXTENSION cube;"
    run "CREATE EXTENSION earthdistance;"
  end

  down do
    run "DROP EXTENSION cube;"
    run "DROP EXTENSION earthdistance;"
  end
end
