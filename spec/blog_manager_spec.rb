require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		@blux= "#{File.dirname(__FILE__)}/.blux"

		@io = mock("IO")
		def @io.<<(str) end
		@manager = BlogManager.new(@io)
	end

	after :each do
		system "rm -Rf #{@blux}"
		system "rm #{@blux_rc}" if File.exists? @blux_rc
	end

	context "loading with no config file" do
		before :each do
			@manager.load_config
		end

		it "should create an empty config file it doesn't exist" do
			File.exists?(@blux_rc).should == true
		end
	end

	context "loading the editor from the config file when it doesn't exist" do
		it "should show a warning" do
			@io.should_receive(:<<).with('please specify an editor in .bluxrc: editor: [your editor of choice]')
			@manager.load_config
		end
	end

	context "loading the editor from the config file" do
		before :each do
			create_config
			@manager.load_config
		end

		it "should read the editor from the config file" do
			@manager.launch_editor_cmd.should == 'gedit'
		end

		def create_config
			config = "editor: gedit"
			system "echo #{config} > #{@blux_rc}"
		end
	end

	context "starting the blog manager" do
		before :each do
			@manager.start
		end

		it "should read the HOME variable from the environment" do
			@manager.home.should == File.dirname(__FILE__)
		end
		
		it "should compute the blux dir" do
			@manager.blux_dir.should == @blux
		end

		it "should compute the bluxrc file" do
			@manager.blux_rc.should == @blux_rc
		end

		it "should clear create a .blux folder in the home dir if it doesn't exist" do
			File.exists?(@blux).should == true
		end

		it "should clear create a draft folder in the .blux dir if it doesn't exist" do
			File.exists?("#{@blux}/drafts").should == true
		end
	end

	#context "creating a draft" do
		#before :each do
			#@manager.start
			#@manager.create_new_draft
		#end
	#end
end
