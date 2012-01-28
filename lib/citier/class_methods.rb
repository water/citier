require 'citier/instance_methods/general_instance_methods'
require 'citier/forced_writers'

module Citier
  module ClassMethods
      def self.extended(base)
        base.send :include, Citier::InstanceMethods
        base.send :include, Citier::ForcedWriters
      end

      def acts_as_citier?
        true
      end

      def [](column_name) 
        arel_table[column_name]
      end
  end
end
