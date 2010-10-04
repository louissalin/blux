require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		@blux = "#{File.dirname(__FILE__)}/.blux"

		Dir.mkdir(@blux) unless Dir.exists?(@blux)

		def STDERR.puts(str) end

		@draft_mgr = DraftManager.new
		@draft_mgr.stub!(:editor_cmd).and_return('gedit')
		@draft_mgr.stub!(:setup)

		@manager = BlogManager.new(@draft_mgr)
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

		it "should create a .blux folder in the home dir if it doesn't exist" do
			File.exists?(@blux).should == true
		end

		it "should create a .tmp folder in the .blux dir if it doesn't exist" do
			File.exists?("#{@blux}/tmp").should == true
		end

		it "should create a draft folder in the .blux dir if it doesn't exist" do
			File.exists?("#{@blux}/draft").should == true
		end

		it "should create a published post file in the .blux dir if it doesn't exist" do
			File.exists?("#{@blux}/.published").should == true
		end
	end

	context "when using the blog manager" do
		before :each do
			File.open("#{@blux}/.published", 'w') do |f|
				f.write('{"draft1.23":{}}')
			end

			@manager.start
		end

		it "should load the published post file" do
			@manager.published_posts.key?("draft1.23").should == true
		end
	end

	context "loading the config and setting up the draft manager" do
		before :each do
			create_config
			@manager.start
		end

		it "should pass the right configuration to the draft manager" do
			@draft_mgr.should_receive(:setup).with('gedit', @manager.blux_tmp_dir, @manager.blux_draft_dir, {:verbose => false})

			@manager.load_config
		end
	end

	context "when publishing" do
		before :each do
			create_config
			@manager.load_config
			@manager.start

			@manager.stub!(:system).and_return(nil)
		end

		it "should send the proper command" do
			@manager.should_receive(:system).with("ruby blux.rb --convert -f draft5.67 | ruby wp_publish.rb -t no title --config #{@blux_rc}")
			@manager.publish 'draft5.67'
		end

		it "should send the command with the title included if it exists" do
			class DraftManager
				def get_attribute(filename, attribute)
					'bla'
				end
			end
			@manager.should_receive(:system).with("ruby blux.rb --convert -f draft5.67 | ruby wp_publish.rb -t bla --config #{@blux_rc}")
			@manager.publish 'draft5.67'
		end

		it "should create a record of the published draft" do
			@manager.publish 'draft5.67'
			@manager.published_posts.key?("draft5.67").should == true
		end
	end

	def create_config
		File.open(@blux_rc, 'w') do |f|
			f.puts "editor: gedit"
			f.puts "html_converter: ruby textile_to_html.rb"
		end
	end
end
