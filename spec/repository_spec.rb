require 'repository'

describe Blux::Repository, "when creating an instance of the repository" do
	it "should create the .blux directory in ~ if it doesn't exist" do
		blux_dir = "#{ENV['HOME']}/.blux"
		Dir.stub(:exist?).with(blux_dir).and_return(false)

		Dir.should_receive(:mkdir).with(blux_dir)
		Blux::Repository.new
	end
end
