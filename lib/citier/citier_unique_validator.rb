module Citier
  # USAGE validates :attribute, :citier_uniqueness => true
  # Needed because validates :attribute, :uniqueness => true  Won't work because it tries to call child_class.attribute on parents table
  class CitierUniquenessValidator < ActiveModel::EachValidator  
    def validate_each(object, attribute, value)
      existing_record = object.class.where(attribute.to_sym => value).limit(1).first
      if existing_record && existing_record.as_root != object.as_root #if prev record exist and it isn't our current obj
        object.errors[attribute] << (options[:message] || "has already been taken.")  
      end 
    end  
  end
end