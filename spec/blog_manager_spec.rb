require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		@blux = "#{File.dirname(__FILE__)}/.blux"
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@draft_dir = "#{@blux_dir}/draft"

		Dir.mkdir(@blux) unless Dir.exists?(@blux)
		Dir.mkdir(@draft_dir) unless Dir.exists?(@draft_dir)

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

			@manager.load_config
			@manager.start

			system "touch #{@manager.draft_dir}/draft5.67"

			@manager.stub!(:system).and_return(true)
		end

		it "should send the proper command" do
			@draft_mgr.stub!(:get_attribute).and_return("title")
			@draft_mgr.stub!(:get_attribute).with("draft5.67", :published_time).and_return(nil)
			@draft_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f draft5.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"title\" --config #{@blux_rc} -c \"title\" | blux --set_edit_url -f draft5.67")
			@manager.publish 'draft5.67'
		end

		it "should send the proper command with categories if there are any" do
			@draft_mgr.stub!(:get_attribute).with("draft5.67", "title").and_return("title")
			@draft_mgr.stub!(:get_attribute).with("draft5.67", "categories").and_return("tag1,tag2")
			@draft_mgr.stub!(:get_attribute).with("draft5.67", :published_time).and_return(nil)
			@draft_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f draft5.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"title\" --config #{@blux_rc} -c \"tag1,tag2\" | blux --set_edit_url -f draft5.67")
			@manager.publish 'draft5.67'
		end

		it "should send the command with the title included if it exists" do
			@draft_mgr.stub!(:get_attribute).and_return('bla')
			@draft_mgr.stub!(:get_attribute).with("draft5.67", :published_time).and_return(nil)
			@draft_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f draft5.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"bla\" --config #{@blux_rc} -c \"bla\" | blux --set_edit_url -f draft5.67")
			@manager.publish 'draft5.67'
		end

		it "should save the record of published drafts to disk" do
			@draft_mgr.stub!(:get_attribute).and_return("title")
			@draft_mgr.stub!(:get_attribute).and_return(nil)
			Time.stub!(:now).and_return('000')
			@draft_mgr.should_receive(:set_attribute).with('draft5.67', :published_time, '000')

			@manager.publish 'draft5.67'
		end

		it "should not allow to publish a draft twice" do
			@draft_mgr.stub!(:get_attribute).and_return('bla')
			@draft_mgr.stub!(:get_attribute).with("draft5.67", :published_time).and_return('123')
			@draft_mgr.stub!(:set_attribute)

			lambda {@manager.publish 'draft5.67'}.should raise_error("this draft has already been published")
		end
	end

	context "when deleting" do
		before :each do
			create_config

			@manager.load_config
			@manager.start

			system "touch #{@manager.draft_dir}/draft5.67"

			@manager.stub!(:system).and_return(true)
			@draft_mgr.stub!(:delete_draft)
			@draft_mgr.stub!(:get_attribute).and_return('http://blablabla.com/asf/1')
		end

		it "should send the proper command" do
			@manager.should_receive(:system).with("ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb --delete http://blablabla.com/asf/1 --config #{@blux_rc} | blux --post-cmd")
			@manager.delete 'draft5.67'
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
