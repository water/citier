require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
require 'citier/view_methods'

ActiveRecord::Schema.define do
  create_table :citier_classes do |t|
    t.column "parent_id4", :integer
  end
  
  create_table :citier_sub_classes do |t|
    t.column "parent_id", :integer
  end
  
  create_table :non_citier_classes do |t|
  end
end

class CitierClass < ActiveRecord::Base
  acts_as_citier
end

class CitierSubClass < ActiveRecord::Base
  acts_as_citier
end

class NonCitierClass < ActiveRecord::Base
end

# create_citier_view(CitierSubClass) 

describe "Adding act_as_citier" do

  it "adds a parent_id field to the writable database table" do
    puts NonCitierClass.column_names.inspect
    puts CitierClass.column_names.inspect
    puts CitierSubClass.column_names.inspect
    CitierSubClass.column_names.should include("parent_id")
  end
end
