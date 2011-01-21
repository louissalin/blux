require 'tempfile'
require 'post_editor'
require 'post'

describe Blux::PostEditor, "when editing a post" do
	before :each do
		@editor = Blux::PostEditor.new
		@post = Blux::Post.new('this is text')
		@tempfile_stub = TempfileStub.new

		def Tempfile.initialize
			return @tempfile_stub
		end
	end

	it "should create a temp file" do
		@editor.edit(@post)
	end

	it "should fill the temp file with the content of the post" do
		Tempfile.stub!(:new).and_return(@tempfile_stub)

		file = mock('file')

		File.should_receive(:open).with('path', 'w').and_yield(file)
		file.should_receive(:puts).with('this is text')
		@editor.edit(@post)
	end
end

class TempfileStub
	def path
		'path'
	end
end
