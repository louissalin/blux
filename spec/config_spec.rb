require 'config'

CONFIG_PATH = "#{ENV['HOME']}/.bluxrc"

describe Blux::ConfigReader, "initialize" do
	before :each do
		File.stub(:exists?).with(CONFIG_PATH ).and_return(false)
		@reader = Blux::ConfigReader.new
	end

	it "should load the default configuration settings" do
		@reader.read_config
		Blux::Config.instance.editor_cmd.should eq("vi")
	end
end

describe Blux::ConfigReader, "override default settings" do
	before :each do
		File.stub(:exists?).with(CONFIG_PATH ).and_return(true)
		ParseConfig.stub(:new)
				   .with(CONFIG_PATH)
				   .and_return(ParseConfigStub.new)

		@reader = Blux::ConfigReader.new
	end

	it "should overload the default config settings if a local config file is found" do
		@reader.read_config
		Blux::Config.instance.editor_cmd.should eq("vim")
	end
end

class ParseConfigStub
	def initialize
		@params = Hash.new
		@params['editor_cmd'] = 'vim'
	end

	def params
		@params
	end
end
