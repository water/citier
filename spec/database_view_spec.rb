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
  #     acts_as_citier
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

  # it "can handle multiple inheritance levels" do
  #   ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
  #   ActiveRecord::Schema.define do
  #     create_table :citier_classes do |t|
  #       t.column "some_root_field", :integer
  #     end
  # 
  #     create_table :citier_sub_classes do |t|
  #       t.column "parent_id", :integer
  #       t.column "some_other_middleman_field", :integer
  #     end
  # 
  #     create_table :citier_sub_sub_classes do |t|
  #       t.column "parent_id", :integer
  #       t.column "some_important_child_field", :integer
  #     end
  #   end
  # 
  #   class CitierClass < ActiveRecord::Base
  #     acts_as_citier
  #   end
  # 
  #   class CitierSubClass < CitierClass
  #     acts_as_citier
  #   end
  #   create_citier_view(CitierSubClass)
  # 
  #   class CitierSubSubClass < CitierSubClass
  #     acts_as_citier
  #   end
  #   create_citier_view(CitierSubSubClass)
  #   
  #   CitierSubClass.column_names.should include("citier_parent_id")
  #   CitierSubSubClass.column_names.should include("citier_parent_id")
  # end

  # it "can handle single level save" do
  #   ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
  #   ActiveRecord::Schema.define do
  #     create_table :citier_classes do |t|
  #       t.column "root_value", :string
  #     end
  # 
  #     create_table :citier_sub_classes do |t|
  #       t.column "parent_id", :integer
  #       t.column "child_value", :string
  #     end
  #   end
  # 
  #   class CitierClass < ActiveRecord::Base
  #     acts_as_citier
  #   end
  # 
  #   class CitierSubClass < CitierClass
  #     acts_as_citier
  #   end
  #   create_citier_view(CitierSubClass)
  #   
  #   CitierClass.create({root_value: "Root_1"})
  #   CitierClass.create({root_value: "Root_2"})
  #   puts CitierClass.all.inspect
  #   CitierSubClass.create({root_value: "Root_3", child_value: "Child_1"})
  #   CitierSubClass.create({root_value: "Root_4", child_value: "Child_2"})
  #   CitierSubClass.create({root_value: "Root_5", child_value: "Child_3"})
  #   puts CitierSubClass.all.inspect
  # end

  it "can handle multi level save" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
        t.column "root_value", :string
      end

      create_table :citier_sub_classes do |t|
        t.column "parent_id", :integer
        t.column "child_value", :string
      end

      create_table :citier_sub_sub_classes do |t|
        t.column "parent_id", :integer
        t.column "subchild_value", :string
      end
    end

    class CitierClass < ActiveRecord::Base
      acts_as_citier
    end

    class CitierSubClass < CitierClass
      acts_as_citier
    end
    create_citier_view(CitierSubClass)

    class CitierSubSubClass < CitierSubClass
      acts_as_citier
    end
    create_citier_view(CitierSubSubClass)

    CitierClass.create({root_value: "Root_1"})
    CitierClass.create({root_value: "Root_2"})
    puts CitierClass.all.inspect
    
    CitierSubClass.create({root_value: "Root_3", child_value: "Child_1"})
    CitierSubClass.create({root_value: "Root_4", child_value: "Child_2"})
    CitierSubClass.create({root_value: "Root_5", child_value: "Child_3"})
    puts CitierSubClass.all.inspect
    
    CitierSubSubClass.create({root_value: "Root_6", child_value: "Child_4", subchild_value: "SubChild_1"})
    CitierSubSubClass.create({root_value: "Root_7", child_value: "Child_5", subchild_value: "SubChild_2"})
    CitierSubSubClass.create({root_value: "Root_8", child_value: "Child_6", subchild_value: "SubChild_3"})
    puts CitierSubSubClass.all.inspect
  end
end
