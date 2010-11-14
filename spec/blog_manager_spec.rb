require 'blog_manager.rb'

describe BlogManager do
	before :each do
		ENV['HOME'] = File.dirname(__FILE__)
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		@blux = "#{File.dirname(__FILE__)}/.blux"
		@blux_dir = "#{File.dirname(__FILE__)}/.blux"
		@post_dir = "#{@blux_dir}/post"

		Dir.mkdir(@blux) unless Dir.exists?(@blux)
		Dir.mkdir(@post_dir) unless Dir.exists?(@post_dir)

		def STDERR.puts(str) end

		@post_mgr = PostManager.new
		@post_mgr.stub!(:editor_cmd).and_return('gedit')
		@post_mgr.stub!(:setup)

		@manager = BlogManager.new(@post_mgr)
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

		it "should create a post folder in the .blux dir if it doesn't exist" do
			File.exists?("#{@blux}/post").should == true
		end
	end

	context "loading the config and setting up the post manager" do
		before :each do
			create_config
			@manager.start
		end

		it "should pass the right configuration to the post manager" do
			@post_mgr.should_receive(:setup).with('gedit', @manager.blux_tmp_dir, @manager.post_dir, {:verbose => false})

			@manager.load_config
		end
	end

	context "when publishing" do
		before :each do
			create_config

			@manager.load_config
			@manager.start

			system "touch #{@manager.post_dir}/post.67"

			@manager.stub!(:system).and_return(true)

			@post = Post.new('post.67', @post_mgr)
			@post.stub!(:edit_url).and_return('http://blablabla.com/asf/1')
		end

		it "should send the proper command" do
			@post.stub!(:published?).and_return(false)
			@post.stub!(:title).and_return('title')
			@post.stub!(:categories).and_return('title')
			@post_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f post.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"title\" --config #{@blux_rc} -c \"title\" | blux --set_edit_url -f post.67")
			@manager.publish @post
		end

		it "should send the proper command with categories if there are any" do
			@post.stub!(:published?).and_return(false)
			@post.stub!(:title).and_return('title')
			@post.stub!(:categories).and_return('tag1,tag2')
			@post_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f post.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"title\" --config #{@blux_rc} -c \"tag1,tag2\" | blux --set_edit_url -f post.67")
			@manager.publish @post
		end

		it "should send the command with the title included if it exists" do
			@post.stub!(:published?).and_return(false)
			@post.stub!(:title).and_return('bla')
			@post.stub!(:categories).and_return('bla')
			@post_mgr.stub!(:set_attribute)

			@manager.should_receive(:system).with("blux --convert -f post.67 | ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb -t \"bla\" --config #{@blux_rc} -c \"bla\" | blux --set_edit_url -f post.67")
			@manager.publish @post
		end

		it "should save the record of published posts to disk" do
			Time.stub!(:now).and_return('000')
			@post.stub!(:published?).and_return(false)
			@post_mgr.should_receive(:set_attribute).with('post.67', "published_time", '000')

			@manager.publish @post
		end

		it "should not allow to publish a post twice" do
			@post.stub!(:published?).and_return(true)
			lambda {@manager.publish @post}.should raise_error("this post has already been published")
		end
	end

	context "when deleting" do
		before :each do
			create_config

			@manager.load_config
			@manager.start

			system "touch #{@manager.post_dir}/post.67"

			@manager.stub!(:system).and_return(true)
			@post_mgr.stub!(:delete_post)

			@post = Post.new('post.67', @post_mgr)
			@post.stub!(:edit_url).and_return('http://blablabla.com/asf/1')
		end

		it "should send the proper command" do
			@manager.should_receive(:system).with("ruby #{File.dirname(__FILE__)[0..-6]}/lib/publishing/wp_publish.rb --delete http://blablabla.com/asf/1 --config #{@blux_rc} | blux --post-cmd")
			@manager.delete @post
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
