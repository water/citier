module Citier
  module ForcedWriters
    def force_attributes(new_attributes, options = {})
      new_attributes = @attributes.merge(new_attributes) if options[:merge]
      @attributes = new_attributes

      if options[:clear_caches] != false
        @aggregation_cache = {}
        @association_cache = {}
        @attributes_cache = {}
      end
    end

    def force_changed_attributes(new_changed_attributes, options = {})
      new_changed_attributes = @attributes.merge(new_changed_attributes) if options[:merge]
      @changed_attributes = new_changed_attributes
    end
  end
end