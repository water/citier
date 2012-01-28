require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'citier/view_methods'
require 'rails_sql_views'



describe "Adding act_as_citier" do

  # it "adds a citier_parent_id field to the writable database table" do
  #   ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
  #   ActiveRecord::Schema.define do
  #     create_table :citier_classes do |t|
  #       t.column "abcdefg", :integer
  #     end
  # 
  #     create_table :citier_sub_classes do |t|
  #       t.column "parent_id", :integer
  #       t.column "some_other_id", :integer
  #     end
  # 
  #     create_view "random_view", "SELECT * FROM citier_sub_classes" do |v|
  #       v.column :id
  #       v.column :some_other_id
  #     end
  # 
  #     create_table :non_citier_classes do |t|
  #     end
  #   end
  # 
  #   class CitierClass < ActiveRecord::Base
  #   end
  # 
  #   class CitierSubClass < CitierClass
  #     acts_as_citier
  #   end
  # 
  #   class NonCitierClass < ActiveRecord::Base
  #   end
  # 
  #   create_citier_view(CitierSubClass)
  # 
  #   CitierSubClass.column_names.should include("citier_parent_id")
  # end
  
  it "can handle multiple inheritance levels" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
        t.column "some_root_field", :integer
      end
  
      create_table :citier_sub_classes do |t|
        t.column "parent_id", :integer
        t.column "some_other_middleman_field", :integer
      end
  
      create_table :citier_sub_sub_classes do |t|
        t.column "parent_id", :integer
        t.column "some_important_child_field", :integer
      end
  
      create_table :non_citier_classes do |t|
      end
    end
  
    class CitierClass < ActiveRecord::Base
    end
  
    class CitierSubClass < CitierClass
      acts_as_citier
    end
    create_citier_view(CitierSubClass)
  
    class CitierSubSubClass < CitierSubClass
      acts_as_citier
    end
    create_citier_view(CitierSubSubClass)
  
    class NonCitierClass < ActiveRecord::Base
    end
    
    CitierSubClass.column_names.should include("citier_parent_id")
    CitierSubSubClass.column_names.should include("citier_parent_id")
  end
end
