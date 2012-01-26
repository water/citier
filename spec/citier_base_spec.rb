require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :citier_classes do |t|
  end
  create_table :non_citier_classes do |t|
  end
end

class CitierClass < ActiveRecord::Base
  acts_as_citier
end

class NonCitierClass < ActiveRecord::Base
end

describe "Implementing 'Acts as Citier'" do
  describe "when adding methods to ActiveRecord::Base with acts_as_citier" do

    it "sucessfully adds acts_as methods to active record" do
      citier_methods = Citier::Base::RequiredMethods.instance_methods
      active_record_methods = ActiveRecord::Base.methods
      
      citier_methods.each do |m|
        active_record_methods.include?(m).should eq(true)
      end
    end

    it "sucessfully adds all citier instance methods to active record instances" do
      citier_methods = Citier::Base::InstanceMethods.instance_methods
      citierclass_methods = CitierClass.new.methods

      citier_methods.each do |m|
        citierclass_methods.include?(m).should eq(true)
      end
    end
  end

  describe "sets the class properties correctly" do

    it "@acts_as_citier = true for citier classes" do
      CitierClass.acts_as_citier?.should eq(true)
    end
    
    it "@acts_as_citier = false for non-citier classes" do
      NonCitierClass.acts_as_citier?.should eq(false)
    end
  end

end