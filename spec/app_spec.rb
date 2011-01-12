require 'app'

describe Blux::App, "initialize" do
	it "should load the config file" do
		stub_config_reader

		Blux::App.new
		Blux::Config.instance.editor_cmd.should eq('vi')

		restore_config_reader
	end

	def stub_config_reader
		Blux::ConfigReader.class_eval do
			alias :old_read_config :read_config

			def read_config
				config = Blux::Config.instance
				config.editor_cmd = 'vi'
			end
		end
	end

	def restore_config_reader
		Blux::ConfigReader.class_eval do
			alias :read_config :old_read_config
		end
	end
end
