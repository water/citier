require 'citier/root_instance_methods.rb'
require 'citier/child_instance_methods'

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
        citier_debug("tablename (view) -> #{self.table_name}")

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
    
    def is_root?
      self.superclass == ActiveRecord::Base
    end

    def acts_as_citier?
      false
    end
  end
end