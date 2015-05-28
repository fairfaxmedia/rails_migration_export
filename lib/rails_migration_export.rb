require "rails_migration_export/version"

module RailsMigrationExport
  require "lib/rails_migration_export/railtie" if defined?(Rails)
end
