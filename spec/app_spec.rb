require 'app'

module AppSpecHelper
	def stub_config_reader
		Blux::ConfigReader.class_eval do
			alias :old_read_config :read_config

			def read_config
				config = Blux::Config.instance
				config.editor_cmd = 'some_editor_cmd'
			end
		end
	end

	def restore_config_reader
		Blux::ConfigReader.class_eval do
			alias :read_config :old_read_config
		end
	end
end

describe Blux::App, "initialize" do
	include AppSpecHelper

	it "should load the config file" do
		stub_config_reader

		Blux::App.new
		Blux::Config.instance.editor_cmd.should eq('some_editor_cmd')

		restore_config_reader
	end
end

describe Blux::App, "when creating a new post" do
	include AppSpecHelper
	#it "should launch the editor defined in the config" do
	it "should create an new post" do
		stub_config_reader

		app = Blux::App.new
		#app.should_receive(:system).with('some_editor_cmd')
		app.create_new_post
		app.current_post.text.should eq('')

		restore_config_reader
	end
end
