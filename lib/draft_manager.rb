require 'tempfile'

class DraftManager
	attr_accessor :launch_editor_cmd
	attr_accessor :temp_file, :temp_dir

	def initialize(editor_cmd, temp_dir)
		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
	end

	def create_new
		@temp_file = Tempfile.new('draft', @temp_dir)
		system @launch_editor_cmd
	end
end
