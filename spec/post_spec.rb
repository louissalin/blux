require 'post.rb'
require "post_manager.rb"

describe Post do
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
end
