module Citier
  module InstanceMethods

    # Sets if the current object is a new record or not
    def is_new_record(b)
      @new_record = b
    end
  end
end