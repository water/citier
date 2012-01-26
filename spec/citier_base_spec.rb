require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

describe "Extending Active Record" do
  
  before :all do
    ActiveRecord::Schema.define do
      create_table :products do |t|
      end
    end

    class Product < ActiveRecord::Base
      acts_as_citier
    end
  end
  
  it "sucessfully adds all citier class methods to active record" do
    citier_methods = Citier::ClassMethods.instance_methods
    active_record_methods = ActiveRecord::Base.methods
    
    citier_methods.each do |m|
      active_record_methods.include?(m).should eq(true)
    end
  
  it "sucessfully adds all citier instance methods to active record instances" do
    citier_methods = Citier::InstanceMethods.instance_methods
    product_methods = Product.new.methods
    
    citier_methods.each do |m|
      active_record_methods.include?(m).should eq(true)
    end
  end
end