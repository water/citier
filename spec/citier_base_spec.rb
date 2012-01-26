require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

describe "Extending active record methods" do

  before :all do
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
      acts_as_citier
    end
  end

  it "sucessfully adds all citier methods to active record" do
    citier_methods = Citier::Base::ClassMethods.instance_methods
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