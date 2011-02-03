require 'repository'
require 'post'
require 'helpers/repository_spec_helper'

describe Blux::Repository, "when creating an instance of the repository" do
	before :each do
		@blux_dir = "#{ENV['HOME']}/.blux"

		pstore = mock('pstore')
		PStore.stub(:new).and_return(pstore)
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

describe Blux::Repository, "when saving posts" do
	include RepositoryTestSetup

	it "should assign a new id of 1 when the repo is empty" do
		setup_pstore_mock()
		@post.id.should eq(1)
	end

	it "should assign a new id incrementally" do
		setup_pstore_mock(1, 2)
		@post.id.should eq(3)
	end

	it "should assign the 1st available id after a post was deleted" do
		setup_pstore_mock(1, 2, 4)
		@post.id.should eq(3)
	end
end
