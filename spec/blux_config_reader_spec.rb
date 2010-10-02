require 'blux_config_reader.rb'

describe BluxConfigurationReader do
	before :each do
		@blux_rc = "#{File.dirname(__FILE__)}/.bluxrc"
		create_config

		@reader = BluxConfigurationReader.new
		@reader.load_config @blux_rc
	end

	context "loading the editor from the config file" do
		it "should read the editor from the config file" do
			@reader.launch_editor_cmd.should == 'gedit'
		end

		it "should read the html_converter from the config file" do
			@reader.html_converter_cmd.should == 'ruby textile_to_html.rb'
		end
	end

	def create_config
		File.open(@blux_rc, 'w') do |f|
			f.puts "editor: gedit"
			f.puts "html_converter: ruby textile_to_html.rb"
		end
	end
end
