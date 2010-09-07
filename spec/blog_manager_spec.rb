require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@manager = BlogManager.new
	end

	it "should read the HOME variable from the environment" do
		@manager.home.should == File.dirname(__FILE__)
	end

	it "should clear create a .blux folder in the home dir if it doesn't exist" do
		File.exists?("#{File.dirname(__FILE__)}/.blux").should == true
	end
end
