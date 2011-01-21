require 'tempfile'
require 'post_editor'
require 'post'
require 'config'

describe Blux::PostEditor, "when editing a post" do
	before :each do
		@editor = Blux::PostEditor.instance
		@post = Blux::Post.new('this is text')
		
		@tempfile_stub = TempfileStub.new
		Tempfile.stub!(:new).and_return(@tempfile_stub)

		@file = mock('file')
		@file.should_receive(:puts).with('this is text')
		File.should_receive(:open).with('path', 'w').and_yield(@file)
	end

	it "should create the temp file with the content of the post" do
		@editor.edit(@post)
	end

	it "should call the editor to edit the temp file" do
		Blux::Config.instance.editor_cmd = 'some_editor_cmd'

		@editor.should_receive(:system).with('some_editor_cmd path')
		@editor.edit(@post)
	end

	it "should not update the post if the editing was not successful" do
		@editor.stub!(:system).with('some_editor_cmd path').and_return(false)

		@editor.edit(@post)
		@post.text.should eq('this is text')
	end

	it "should update the post if the editing was successful" do
		@editor.stub!(:system).with('some_editor_cmd path').and_return(true)

		File.should_receive(:open).with('path', 'r').and_yield(@file)
		@file.should_receive(:read).and_return('new text')

		@editor.edit(@post)
		@post.text.should eq('new text')
	end
end

class TempfileStub
	def path
		'path'
	end
end
