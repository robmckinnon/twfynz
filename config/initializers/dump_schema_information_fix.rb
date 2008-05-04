module ActiveRecord
  module ConnectionAdapters # :nodoc:
    module SchemaStatements

      def dump_schema_information #:nodoc:
        begin
          sm_table = ActiveRecord::Migrator.schema_migrations_table_name
          migrated = select_values("SELECT version FROM #{sm_table}")
          migrated.map { |v| "INSERT INTO #{sm_table} (version) VALUES ('#{v}');" }.join("\n")
        rescue Exception
          begin
            if (current_schema = ActiveRecord::Migrator.current_version) > 0
              return "INSERT INTO #{quote_table_name(ActiveRecord::Migrator.schema_info_table_name)} (version) VALUES (#{current_schema})"
            end
          rescue ActiveRecord::StatementInvalid
            # No Schema Info
          end
        end
      end

    end
  end
end
