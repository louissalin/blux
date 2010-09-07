require 'draft_manager.rb'

describe DraftManager do
	before :each do
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@temp_dir = "#{@blux_dir}/tmp"

		Dir.mkdir(@blux_dir) unless Dir.exists?(@blux_dir)
		Dir.mkdir(@temp_dir) unless Dir.exists?(@temp_dir)

		@manager = DraftManager.new('gedit', @temp_dir)
	end

	after :each do
		system "rm -Rf #{@blux}"
	end

	context "when creating a new draft manager" do
		before :each do
			@manager.stub!(:system).and_return(nil)
		end

		it "should create a temporary file" do
			@manager.create_new
			@manager.temp_file.should_not == nil
		end

		it "should call the editor command" do
			@manager.should_receive(:system).with('gedit')
			@manager.create_new
		end
	end
end

