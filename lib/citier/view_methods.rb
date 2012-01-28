require 'citier/forced_writers'

# Creates a view by pulling in the relevant fields for the current class
# from all it's parent classes.
# Keeping a seperate view means we read all attributes from one table which
# is much faster than pulling them all in seperately using model-logic
# 
require 'rails_sql_views'

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
# * Clear the column cache so it gets regenerated on the next request
#
# create_view uses the rails_sql_views gem
def create_citier_view(klass)
  self_columns = klass::Writable.column_names.select{ |c| c != klass.citier_parent_field }
  parent_columns = klass.superclass.column_names.select{ |c| c != "id" }
  self_read_table = klass.table_name
  self_write_table = klass::Writable.table_name
  parent_read_table = klass.superclass.table_name

  citier_debug("Creating citier view")

  sql = ""
  sql += "SELECT C.#{klass.citier_parent_field} AS citier_parent_id, " 
  sql += "#{self_columns.map{|c| "C.#{c}"}.join(', ')}"
  # sql += " "
  sql += ", "
  sql += "#{parent_columns.map{|c| "P.#{c}"}.join(', ')} "
  sql += "FROM #{parent_read_table} P, #{self_write_table} C " 
  sql += "WHERE P.id = citier_parent_id"

  ActiveRecord::Schema.define do
    create_view "#{self_read_table}", sql do |v|
      v.column :id
      (self_columns + parent_columns).each do |c|
        v.column c.to_sym
      end
    end
  end
  
  reset_class = klass
  until !reset_class.acts_as_citier?
    citier_debug("Resetting column information for class #{reset_class}")
    reset_class.reset_column_information
    reset_class::Writable.reset_column_information
    reset_class = reset_class.superclass
  end
end

# Drops the generated view for the given class.
# drop_view uses the rails_sql_views gem
def drop_citier_view(klass) #function for dropping views for migrations 
  self_read_table = klass.table_name
  ActiveRecord::Schema.define do
    drop_view self_read_table.to_sym
  end
  citier_debug("Dropping citier view)")
end

# Regenerates the view for the given class.
# Basically just drops the citier view for the class and then re-creates it
# Shoudl throw an error if the klass doesn't have a table.
# See #create_or_update_citier_view for a method which doesn't throw an error
# but instead just creates the table if none already exists
def update_citier_view(klass) #function for updating views for migrations
  citier_debug("Updating citier view for #{klass}")
  if klass.table_exists?
    drop_citier_view(klass)
    create_citier_view(klass)
  else
    # TODO: Raise an error here!
    citier_debug("Error: #{klass} VIEW doesn't exist.")
  end
end

# Checks to see if a table exists for the given class. If not, create one, else
# update the citier view for the class. Ensures a table will exist regardless
# of whether it already exists
def create_or_update_citier_view(klass)
  citier_debug("Create or Update citier view for #{klass}")
  if klass.table_exists?
    update_citier_view(klass)
  else
    citier_debug("VIEW DIDN'T EXIST. Now creating for #{klass}")
    create_citier_view(klass)
  end
end


def create_class_writable(class_reference)
  Class.new(ActiveRecord::Base) do
    include Citier::ForcedWriters
    self.table_name = get_writable_table(class_reference.table_name)
  end
end

# Strips 'view_' from the table name if it exists
def get_writable_table(table_name)
  if table_name[0..4] == "view_"
    return table_name[5..table_name.length]
  end
  return table_name
end