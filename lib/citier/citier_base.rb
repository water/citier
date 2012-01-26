module Citier
  module Base
    def self.included(base)
      base.send :extend, Citier::RequiredMethods
    end
  end
end

ActiveRecord::Base.send :include, Citier::Base