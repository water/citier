module Citier
  module InstanceMethods
    
    # Sets if the current object is a new record or not
    def is_new_record(b)
      @new_record = b
    end
    
    # Creates a view by pulling in the relevant fields for the current class
    # from all it's parent classes.
    # Keeping a seperate view means we read all attributes from one table which
    # is much faster than pulling them all in seperately using model-logic
    # 
    # The basic steps are as follows:
    # * Reset all cached column information for this and all parent classes
    # * Gather all non-id columns for the current class
    # * Gather all non-id columns for the parents class - note: if the parent 
    #   class is itself a subclass, it will retrieve these from it's view
    # * Obtain the (current) readable and writable table for the current class
    # * Obtain the table for the parent class
    # * Generate a view named after the default table name for the class which 
    #   pulls in columns from its own writable table and the readable table for
    #   it's parent based on the columns retrieved earlier. 
    #
    # create_view uses the rails_sql_views gem
    def create_citier_view(klass)
      reset_class = klass::Writable 
      until reset_class == ActiveRecord::Base
        citier_debug("Resetting column information on #{reset_class}")
        reset_class.reset_column_information
        reset_class = reset_class.superclass
      end

      self_columns = klass::Writable.column_names.select{ |c| c != "id" }
      parent_columns = klass.superclass.column_names.select{ |c| c != "id" }
      columns = parent_columns + self_columns
      self_read_table = klass.table_name
      self_write_table = klass::Writable.table_name
      parent_read_table = klass.superclass.table_name
      
      create_view self_read_table, "SELECT #{parent_read_table}.id, #{columns.join(',')} FROM #{parent_read_table}, #{self_write_table} WHERE #{parent_read_table}.id = #{self_write_table}.id" do |v|
        v.column :id
        columns.each do |c|
          v.column c.to_sym
        end
      end

      citier_debug("Creating citier view -> #{sql}")
    end
    
    # Drops the generated view for the given class.
    # drop_view uses the rails_sql_views gem
    def drop_citier_view(klass) #function for dropping views for migrations 
      self_read_table = klass.table_name
      drop_view self_read_table.to_sym
      citier_debug("Dropping citier view -> #{sql}")
    end

    def update_citier_view(klass) #function for updating views for migrations
      citier_debug("Updating citier view for #{klass}")
      if klass.table_exists?
        drop_citier_view(klass)
        create_citier_view(klass)
      else
        citier_debug("Error: #{klass} VIEW doesn't exist.")
      end
    end

    def create_or_update_citier_view(klass) #Convienience function for updating or creating views for migrations
      citier_debug("Create or Update citier view for #{klass}")

      if klass.table_exists?
        update_citier_view(klass)
      else
        citier_debug("VIEW DIDN'T EXIST. Now creating for #{klass}")
        create_citier_view(klass)
      end
    end
  end
end