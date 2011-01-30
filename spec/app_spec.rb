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

	it "should call the editor to edit the post, and then save the post" do
		stub_config_reader

		app = Blux::App.new

		post = mock('post')
		Blux::Post.should_receive(:new).and_return(post)

		post.should_receive(:edit)
		post.should_receive(:save)
		app.create_new_post

		restore_config_reader
	end
end
