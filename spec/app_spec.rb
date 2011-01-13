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

	before :all do
		stub_config_reader
	end

	before :each do
		@app = Blux::App.new
	end

	it "should create an new post" do
		@app.create_new_post
		@app.current_post.text.should eq('')
	end

	it "should call the editor to edit the post" do
		class Blux::Post
			def edit
				@text = 'asdfasdf'
			end
		end

		@app.create_new_post
		@app.current_post.text.should eq('asdfasdf')
	end

	after :all do
		restore_config_reader
	end
end
