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

	context "loading the config with missing items" do
		before :each do
			@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
			@reader = BluxConfigurationReader.new
		end

		it "should raise an exception when the editor is missing" do
			create_empty_config
			lambda {@reader.load_config @blux_rc}.should raise_error("please specify an editor in .bluxrc:\n  editor: [your editor of choice]")
		end

		it "should raise an exception when the blog name is missing" do
			lines = ["editor: gedit",
					 "author_name: Author Bob",
					 "user_name: this_user",
					 "password: pass123"]
			
			create_config_with lines
			lambda {@reader.load_config @blux_rc}.should raise_error("please specify your wordpress blog name in .bluxrc:\n  blog: [your blog]")
		end

		it "should raise an exception when the author name is missing" do
			lines = ["editor: gedit",
					 "blog: myownblog",
					 "user_name: this_user",
					 "password: pass123"]
			
			create_config_with lines
			lambda {@reader.load_config @blux_rc}.should raise_error("please specify an author name in .bluxrc:\n  author_name: [your name]")
		end

		it "should raise an exception when the user name is missing" do
			lines = ["editor: gedit",
					 "blog: myownblog",
					 "author_name: Author Bob",
					 "password: pass123"]

			create_config_with lines
			lambda {@reader.load_config @blux_rc}.should raise_error("please specify your wordpress user name in .bluxrc:\n  user_name: [your user name]")
		end

		it "should raise an exception when the password is missing" do
			lines = ["editor: gedit",
					 "blog: myownblog",
					 "author_name: Author Bob",
					 "user_name: this_user"]

			create_config_with lines
			lambda {@reader.load_config @blux_rc}.should raise_error("please specify your wordpress password in .bluxrc:\n  password: [your password]")
		end
	end

	def create_empty_config
		File.open(@blux_rc, 'w') do |f|
		end
	end

	def create_config_with(lines)
		File.open(@blux_rc, 'w') do |f|
			lines.each {|l| f.puts l}
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
