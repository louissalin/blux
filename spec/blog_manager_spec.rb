require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		@blux = "#{File.dirname(__FILE__)}/.blux"
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@draft_dir = "#{@blux_dir}/draft"

		Dir.mkdir(@blux) unless Dir.exists?(@blux)

		def STDERR.puts(str) end

		@draft_mgr = DraftManager.new
		@draft_mgr.stub!(:editor_cmd).and_return('gedit')
		@draft_mgr.stub!(:setup)
		@draft_mgr.stub!(:draft_dir).and_return(@draft_dir)

		@manager = BlogManager.new(@draft_mgr)
	end

	after :each do
		system "rm -Rf #{@blux}"
		system "rm #{@blux_rc}" if File.exists? @blux_rc
	end

	context "loading with no config file" do
		before :each do
			lambda {@manager.load_config}.should raise_error
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
			@manager.index.key?("draft1.23").should == true
		end
	end

	context "loading the config and setting up the draft manager" do
		before :each do
			create_config
			@manager.start
		end

		it "should pass the right configuration to the draft manager" do
			@draft_mgr.should_receive(:setup).with('gedit', @manager.blux_tmp_dir, @manager.draft_dir, {:verbose => false})

			@manager.load_config
		end
	end

	context "when publishing" do
		before :each do
			create_config

			File.open(@manager.index_file, 'w') do |f|
				f.write('{"draft5.67":{"a":1,"b":2}}')
			end

			@manager.load_config
			@manager.start

			system "touch #{@manager.draft_dir}/draft5.67"

			@manager.stub!(:system).and_return(nil)
		end

		it "should send the proper command" do
			@manager.should_receive(:system).with("blux --convert -f draft5.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/wp_publish.rb -t no title --config #{@blux_rc} | blux --set_edit_url -f draft5.67")
			@manager.publish 'draft5.67'
		end

		it "should send the command with the title included if it exists" do
			@draft_mgr.stub!(:get_attribute).and_return('bla')

			@manager.should_receive(:system).with("blux --convert -f draft5.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/wp_publish.rb -t bla --config #{@blux_rc} | blux --set_edit_url -f draft5.67")
			@manager.publish 'draft5.67'
		end

		it "should save the record of published drafts to disk" do
			@manager.publish 'draft5.67'

			lines = ''
			File.open(@manager.index_file, 'r') do |f| 
				f.each_line {|l| lines += l}
			end

			JSON.parse(lines).key?('draft5.67').should == true
		end

		it "should add the published time to the attributes of that post" do
			time = Time.now.to_s

			@manager.publish 'draft5.67'
			@manager.index["draft5.67"]["published_time"].to_s.should == time
		end
	end

	def create_config
		File.open(@blux_rc, 'w') do |f|
			f.puts "editor: gedit"
			f.puts "html_converter: blux_textile_to_html"

			f.puts "blog: louis"
			f.puts "author_name: louis"
			f.puts "user_name: louis"
			f.puts "password: password"
		end
	end
end
