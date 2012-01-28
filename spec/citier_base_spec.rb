require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Adding methods to ActiveRecord::Base with acts_as_citier" do

  it "sucessfully adds acts_as methods to active record" do
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

    citier_methods = Citier::RequiredMethods.instance_methods
    active_record_methods = ActiveRecord::Base.methods

    citier_methods.each do |m|
      active_record_methods.include?(m).should eq(true)
    end
  end

  it "sucessfully adds class methods to classes which act as citier" do
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
    citier_methods = Citier::ClassMethods.instance_methods
    active_record_methods = CitierClass.methods

    citier_methods.each do |m|
      active_record_methods.include?(m).should eq(true)
    end
  end

  it "sucessfully adds all citier instance methods to active record instances" do
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

    citier_methods = Citier::InstanceMethods.instance_methods
    citierclass_methods = CitierClass.new.methods

    citier_methods.each do |m|
      citierclass_methods.include?(m).should eq(true)
    end
  end

  it "doesn't add citier class methods to non-citier classes" do
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

    citier_methods = Citier::ClassMethods.instance_methods
    citierclass_methods = NonCitierClass.methods
    citierclass_methods.delete(:acts_as_citier?) # Should be in both

    citier_methods.each do |m|
      citierclass_methods.include?(m).should eq(false)
    end
  end

  it "doesn't add citier instance methods to non-citier instances" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
      end
      create_table :non_citier_classes do |t|
      end
    end
    citier_methods = Citier::InstanceMethods.instance_methods
    citierclass_methods = NonCitierClass.new.methods

    citier_methods.each do |m|
      citierclass_methods.include?(m).should eq(false)
    end
  end
end

describe "identifying citier vs non citier classes" do

  it "identifies an acts_as_citier class" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
      end
      create_table :non_citier_classes do |t|
      end
    end
    CitierClass.acts_as_citier?.should eq(true)
  end

  it "identifies a non acts_as_citier class" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
      end
      create_table :non_citier_classes do |t|
      end
    end
    NonCitierClass.acts_as_citier?.should eq(false)
  end
end

describe "retrieving the writable version of a table" do
  it "should strip 'view_' from the start of a table name" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
      end
      create_table :non_citier_classes do |t|
      end
    end
    get_writable_table("view_some_table").should eq("some_table")
    get_writable_table("view_anothertable").should eq("anothertable")
  end

  it "should not alter a table name without a 'view_' prefix" do
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
    ActiveRecord::Schema.define do
      create_table :citier_classes do |t|
      end
      create_table :non_citier_classes do |t|
      end
    end
    get_writable_table("a_table").should eq("a_table")
    get_writable_table("vieww_something").should eq("vieww_something")
    get_writable_table("vie_something").should eq("vie_something")
    get_writable_table("aview_something").should eq("aview_something")
    get_writable_table("a_view_something").should eq("a_view_something")
  end
end
