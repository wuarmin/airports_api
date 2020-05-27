require './config/environment'

namespace :db do
  require 'sequel'
  require 'sequel/extensions/seed'

  Sequel.extension :migration
  Sequel.extension :seed

  desc "Perform database migration"
  task :migrate do
    version = Sequel::Migrator.run(DB, "db/migrations", table: Sequel[:public][:_schema_info])
    puts "<= sq:migration:to version=[#{version}] executed"
  end

  desc "Perform migration reset (migrate down to version 0 and up to latest)"
  task :reset do
    Sequel::Migrator.run(DB, "db/migrations", :target => 0, table: Sequel[:public][:_schema_info])
    Sequel::Migrator.run(DB, "db/migrations", table: Sequel[:public][:_schema_info])
    puts "<= sq:migrate:reset executed"
  end

end
