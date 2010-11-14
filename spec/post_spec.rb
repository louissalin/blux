require 'post.rb'
require "post_manager.rb"

describe Post do
	context "when setting the published_time" do
		before(:all) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'published_time', Time.now.to_s)
			@post.published_time = Time.now
		end
	end

	context "when setting the creation_time" do
		before(:all) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'creation_time', Time.now.to_s)
			@post.creation_time = Time.now
		end
	end

	context "when setting the edited_time" do
		before(:all) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'edited_time', Time.now.to_s)
			@post.edited_time = Time.now
		end
	end

	context "when setting the title" do
		before(:all) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'title', 'new title')
			@post.title = 'new title'
		end
	end

	context "when setting the edit_url" do
		before(:all) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'edit_url', 'http://some_url/')
			@post.edit_url = 'http://some_url/'
		end
	end

	context "when adding a category" do
		before(:each) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
		end

		it "should set the attribute in the post manager" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'categories', 'cat1')
			@post.add_category('cat1')
		end

		it "should overwrite the old categories with a list of new ones" do
			@post.add_category('cat1')
			@post.add_category('cat2')

			@manager.should_receive(:set_attribute).with('draft1.23', 'categories', 'cat1,cat2,cat3')
			@post.add_category('cat3')
		end

		it "should add the category to the list" do
			@post.add_category('cat1')
			@post.categories.should == 'cat1'

			@post.add_category('cat2')
			@post.categories.should == 'cat1,cat2'
		end

		it "should not allow duplicates" do
			@post.add_category('cat1')
			@post.add_category('cat1')

			@post.categories.should == 'cat1'
		end

		it "should not set the attributes with duplicates" do
			@post.add_category('cat1')

			@manager.should_not_receive(:set_attribute)
			@post.add_category('cat1')
		end
	end

	context "when deleting a category" do
		before(:each) do
			@manager = PostManager.new
			@manager.stub!(:set_attribute)

			@post = Post.new('draft1.23', @manager)
			@post.add_category('cat1')
			@post.add_category('cat2')
			@post.add_category('cat3')
		end

		it "should delete that category" do
			@post.delete_category('cat2')
			@post.categories.should == 'cat1,cat3'
		end

		it "should reset the attribute with the remaining categories" do
			@manager.should_receive(:set_attribute).with('draft1.23', 'categories', 'cat2,cat3')
			@post.delete_category('cat1')
		end

		it "should allow deleting all categories" do
			@post.delete_category('cat1')
			@post.delete_category('cat2')

			@manager.should_receive(:set_attribute).with('draft1.23', 'categories', '')
			@post.delete_category('cat3')
		end
	end
end
