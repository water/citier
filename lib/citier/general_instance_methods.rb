module Citier
  module InstanceMethods
    def is_new_record(state)
      @new_record = state
    end

    def create_citier_view(theclass)
      # function for creating views for migrations 
      # flush any column info in memory
      # Loops through and stops once we've cleaned up to our root class.
      # We MUST user Writable as that is the place where changes might reside!
      reset_class = theclass::Writable 
      until reset_class == ActiveRecord::Base
        citier_debug("Resetting column information on #{reset_class}")
        reset_class.reset_column_information
        reset_class = reset_class.superclass
      end

      self_columns = theclass::Writable.column_names.select{ |c| c != "id" }
      parent_columns = theclass.superclass.column_names.select{ |c| c != "id" }
      columns = parent_columns+self_columns
      self_read_table = theclass.table_name
      self_write_table = theclass::Writable.table_name
      parent_read_table = theclass.superclass.table_name
      sql = "CREATE VIEW #{self_read_table} AS SELECT #{parent_read_table}.id, #{columns.join(',')} FROM #{parent_read_table}, #{self_write_table} WHERE #{parent_read_table}.id = #{self_write_table}.id" 

      #Use our rails_sql_views gem to create the view so we get it outputted to schema
      create_view "#{self_read_table}", "SELECT #{parent_read_table}.id, #{columns.join(',')} FROM #{parent_read_table}, #{self_write_table} WHERE #{parent_read_table}.id = #{self_write_table}.id" do |v|
        v.column :id
        columns.each do |c|
          v.column c.to_sym
        end
      end

      citier_debug("Creating citier view -> #{sql}")
    end

    def drop_citier_view(theclass) #function for dropping views for migrations 
      self_read_table = theclass.table_name
      sql = "DROP VIEW #{self_read_table}"

      drop_view(self_read_table.to_sym) #drop using our rails sql views gem

      citier_debug("Dropping citier view -> #{sql}")
      #theclass.connection.execute sql
    end

    def update_citier_view(theclass) #function for updating views for migrations
      citier_debug("Updating citier view for #{theclass}")
      if theclass.table_exists?
        drop_citier_view(theclass)
        create_citier_view(theclass)
      else
        citier_debug("Error: #{theclass} VIEW doesn't exist.")
      end
    end

    def create_or_update_citier_view(theclass) #Convienience function for updating or creating views for migrations
      citier_debug("Create or Update citier view for #{theclass}")

      if theclass.table_exists?
        update_citier_view(theclass)
      else
        citier_debug("VIEW DIDN'T EXIST. Now creating for #{theclass}")
        create_citier_view(theclass)
      end
    end
  end
end