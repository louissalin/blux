require 'repository'

describe Blux::Repository, "when creating an instance of the repository" do
	before :each do
		@blux_dir = "#{ENV['HOME']}/.blux"
	end

	it "should create the .blux directory in ~ if it doesn't exist" do
		Dir.stub(:exist?).with('test').and_return(false)

		Dir.should_receive(:mkdir).with('test')
		Blux::Repository.new('test')
	end

	it "should not create the .blux directory if it exists" do
		Dir.stub(:exist?).with(@blux_dir).and_return(true)

		Dir.should_not_receive(:mkdir).with(@blux_dir)
		Blux::Repository.new(@blux_dir)
	end

	it "should default the location to ~/.blux" do
		Dir.stub(:exist?).with(@blux_dir).and_return(false)

		Dir.should_receive(:mkdir).with(@blux_dir)
		Blux::Repository.new
	end
end
