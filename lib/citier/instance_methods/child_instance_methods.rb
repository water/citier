module Citier
  module ChildInstanceMethods
    
    # Handles the saving of a model.
    # Seperates out the writable fields for the current class and those which
    # belong 'to its parent classes. Then retrieves the writable table for each
    # and saves the attributes.
    #
    # Returns false if the :validate option is set to false or the current class
    # is not valid.
    # * Runs callbacks for save/create/update just like ActiveRecord
    # * Gather class attributes which belong to the parent model, isolating 
    #   those which have changed so we don't make unecessary DB calls
    # * Gather class attributes which belong to this class, not any parents and 
    #   isolate those which have changed so we don't make unecessary DB calls
    # * Create a new instance of the parent class, forcing it to take on the 
    #   attributes we just extracted
    # * The parent is set to be the same new_record setting as the current class
    #   so if this is a new object, the parent knows it needs to be created as a 
    #   new object too
    # * Save the parent model. If the parent is also subclasses that's fine, 
    #   it will also call this method.
    # * Check to see if there are any attributes for the current class. If so, 
    #   same drill as with the parent class
    # * All parent and current classes have saved successfully. Set new_record 
    #   to false and force the changed attributes to be none/empty so future 
    #   changes will be recognised
    def save(options={})
      return false if (options[:validate] != false && !self.valid?)
      
      citier_debug("Saving #{self.class.to_s}")
      
      self.run_callbacks(:save) do
        self.run_callbacks(self.new_record? ? :create : :update) do
          attributes_for_parent = self.attributes.reject { |key,value| !self.class.superclass.column_names.include?(key) }
          changed_attributes_for_parent = self.changed_attributes.reject { |key,value| !self.class.superclass.column_names.include?(key) }

          attributes_for_current = self.attributes.reject { |key,value| self.class.superclass.column_names.include?(key) }
          changed_attributes_for_current = self.changed_attributes.reject { |key,value| self.class.superclass.column_names.include?(key) }

          citier_debug("Attributes for #{self.class.superclass.to_s}: #{attributes_for_parent.inspect}")
          citier_debug("Changed attributes for #{self.class.superclass.to_s}: #{changed_attributes_for_parent.keys.inspect}")
          citier_debug("Attributes for #{self.class.to_s}: #{attributes_for_current.inspect}")
          citier_debug("Changed attributes for #{self.class.to_s}: #{changed_attributes_for_current.keys.inspect}")

          parent = self.class.superclass.new
          parent.force_attributes(attributes_for_parent, :merge => true)
          parent.force_changed_attributes(changed_attributes_for_parent)
          
          parent.is_new_record(new_record?)
          if !parent.save
            citier_debug("Parent Class (#{self.class.superclass.to_s}) could not be saved")
            citier_debug("Errors = #{parent.errors.to_s}")
            return false
          else
            if parent.class.is_root?
              citier_debug("Saved #{parent.class.name} ")
            end
          end
          
          if attributes_for_current.any?
            current = self.class::Writable.new
            
            current.force_attributes(attributes_for_current, :merge => true)
            current.force_changed_attributes(changed_attributes_for_current)
            current.id = self.id
            if new_record?
              current[self.class.citier_parent_field.to_sym] = parent.id
              self.citier_parent_id = parent.id
            end
            current.is_new_record(new_record?)
            
            if !current.save
              citier_debug("Class (#{self.class.superclass.to_s}) could not be saved")
              citier_debug("Errors = #{current.errors.to_s}")
              return false
            else
              self.id = current.id
              citier_debug("Saved #{self.class.name} ")
            end
          end
          
          is_new_record(false)
          self.force_changed_attributes({})
        end
      end
      return true
    end
  
    def save!(options={})
      raise ActiveRecord::RecordInvalid.new(self) if (options[:validate] != false && !self.valid?)
      self.save || raise(ActiveRecord::RecordNotSaved)
    end
  end
end