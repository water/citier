module Citier
  module ClassMethods
      def self.extended(base)
        base.send :include, Citier::InstanceMethods
      end

      def acts_as_citier?
        true
      end

      def [](column_name) 
        arel_table[column_name]
      end

      def create_class_writable(class_reference)
        Class.new(ActiveRecord::Base) do
          include Citier::ForcedWriters

          # set the name of the writable table associated with the class_reference class
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
  end
end
