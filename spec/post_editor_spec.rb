require 'tempfile'
require 'post_editor'
require 'post'

describe Blux::PostEditor, "when editing a post" do
	it "should create a temp file" do
		editor = Blux::PostEditor.new
		post = Blux::Post.new('this is text')

		Tempfile.should_receive(:new).with('blux')
		editor.edit(post)
	end

	it "should fill the temp file with the content of the post" do
		stub = TempfileStub.new
		Tempfile.stub!(:new).and_return(stub)

		editor = Blux::PostEditor.new
		post = Blux::Post.new('this is text')

		File.should_receive(:open).with('path')
		editor.edit(post)
	end
end

class TempfileStub
	def path
		puts 'test'
		'path'
	end
end
