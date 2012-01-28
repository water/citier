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
  end
end
