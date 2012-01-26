require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :products do |t|
    t.string :type
    t.string :name
    t.decimal :price
  end
end

class Product < ActiveRecord::Base
  acts_as_citier
  validates_presence_of :name
  def an_awesome_product
    puts "I #{name} am an awesome product"
  end
end

describe "Extending Active Record" do
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