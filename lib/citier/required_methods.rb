require 'citier/instance_methods/root_instance_methods.rb'
require 'citier/instance_methods/child_instance_methods'

module Citier
  module RequiredMethods

    def acts_as_citier(options = {})
      self.new.class.send :extend, Citier::ClassMethods

      #:table_name = option for setting the name of the current class table_name, default value = 'tableized(current class name)'
      table_name = (options[:table_name] || self.name.tableize.gsub(/\//,'_')).to_s
      if !is_root?
        citier_debug("Non Root Class")
        citier_debug("table_name -> #{table_name}")

        # Set up the table which contains ALL attributes we want for this class
        self.table_name = "view_#{table_name}"
        
        @@parent_field = options[:parent_field] || :parent_id
        
        if !self.column_names.include?(@@parent_field)
          # add_column self.table_name.to_sym, @@parent_field, :integer
          raise "#{@@parent_field} is not available for #{self.name}"#TODO: Handle me properly
        end
        
        # Create a writable version of this class
        self.const_set("Writable", create_class_writable(self))

        after_initialize do
          self.id = nil if self.new_record? && self.id == 0
        end
        send :include, Citier::ChildInstanceMethods
      else
        citier_debug("Root Class")
        self.table_name = "#{table_name}"
        citier_debug("table_name -> #{self.table_name}")

        # Add the functions required for root classes only
        send :include, Citier::RootInstanceMethods
      end
    end
    
    # Returns true if the current class doesn't inherit from another class.
    # This is the case if it inherits from ActiveRecord::Base
    def is_root?
      self.superclass == ActiveRecord::Base
    end

    def acts_as_citier?
      false
    end
  end
end