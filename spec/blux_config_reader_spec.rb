require 'blux_config_reader.rb'

describe BluxConfigurationReader do
	before :each do
		def STDERR.puts(str) end
	end

	after :each do
		system "rm #{@blux_rc}" if File.exists? @blux_rc
	end

	context "loading the editor from the config file" do
		before :each do
			@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
			create_config

			@reader = BluxConfigurationReader.new
			@reader.load_config @blux_rc
		end

		it "should read the editor from the config file" do
			@reader.launch_editor_cmd.should == 'gedit'
		end

		it "should read the html_converter from the config file" do
			@reader.html_converter_cmd.should == 'ruby textile_to_html.rb'
		end

		it "should read the blog from the config file" do
			@reader.blog.should == 'myownblog'
		end

		it "should read the blog from the config file" do
			@reader.author_name.should == 'Author Bob'
		end

		it "should read the blog from the config file" do
			@reader.user_name.should == 'this_user'
		end

		it "should read the blog from the config file" do
			@reader.password.should == 'pass123'
		end
	end

	context "loading the editor from the config file when it doesn't exist" do
		before :each do
			@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
			create_empty_config

			@reader = BluxConfigurationReader.new
			@reader.load_config @blux_rc
		end

		it "should show a warning" do
			STDERR.should_receive(:puts).with("please specify an editor in .bluxrc: editor: [your editor of choice]\n")
			STDERR.should_receive(:puts).with("please specify an html converter in .bluxrc: html_converter: [your converter command of choice]\n")
			STDERR.should_receive(:puts).with("please specify your wordpress blog name in .bluxrc: blog: [your blog]\n")
			STDERR.should_receive(:puts).with("please specify an author name in .bluxrc: author_name: [your name]\n")
			STDERR.should_receive(:puts).with("please specify your wordpress user name in .bluxrc: user_name: [your user name]\n")
			STDERR.should_receive(:puts).with("please specify your wordpress password in .bluxrc: password: [your password]\n")
			@reader.load_config @blux_rc
		end
	end

	def create_empty_config
		File.open(@blux_rc, 'w') do |f|
		end
	end

	def create_config
		File.open(@blux_rc, 'w') do |f|
			f.puts "editor: gedit"
			f.puts "html_converter: ruby textile_to_html.rb"
			f.puts "blog: myownblog"
			f.puts "author_name: Author Bob"
			f.puts "user_name: this_user"
			f.puts "password: pass123"
		end
	end
end
