require 'rails_migration_export'
require 'rails'

module RailsMigrationExport
  class Railtie < Rails::Railtie
    rake_tasks do
      namespace :db do
        namespace :migrate do
          default_command = 'db:migrate:redo'

          desc "Export the SQL for specified migrations (defaults to #{default_command})"
          task :export_sql, [:command] => :environment do |t, args|
            migration_command = args[:command] || default_command
            puts "Collecting SQL for #{migration_command}"
            results = RailsMigrationExport::Exporter.new.with_logging(args[:params]) do
              Rake::Task[migration_command].invoke(*args)
            end

            puts "\nGenerated SQL:"
            results.each do |result|
              puts result
            end
            puts "\n"
          end
        end
      end
    end
  end
end
