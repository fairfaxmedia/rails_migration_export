require "rails_migration_export/version"

module RailsMigrationExport
  require "rails_migration_export/railtie" if defined?(Rails)

  class Exporter
    attr_accessor :results

    def connection_class
      ActiveRecord::Base.connection.class
    end

    def hook_connection
      exporter = self
      connection_class.send(:alias_method, :unlogging_execute, :execute)
      connection_class.send(:define_method, :logging_execute) do |*args|
        exporter.results << args[0]
        unlogging_execute(*args)
      end
      connection_class.send(:alias_method, :execute, :logging_execute)
    end

    def unhook_connection
      connection_class.send(:alias_method, :execute, :unlogging_execute)
      connection_class.send(:remove_method, :logging_execute)
    end

    def with_logging(params)
      self.results = []
      hook_connection
      yield
      unhook_connection
      filtered_results
    end

    def filtered_results
      results.reject do |result|
        result.start_with? 'SHOW'
      end.reject do |result|
        result =~ /schema_migrations/
      end
    end
  end
end
