require 'app'
require 'helpers/app_spec_helper'

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
	it "should create an new post" do
		stub_config_reader

		app = Blux::App.new
		app.create_new_post
		app.current_post.text.should eq('')

		restore_config_reader
	end
end
