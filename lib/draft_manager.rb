require 'tempfile'

class DraftManager
	attr_accessor :launch_editor_cmd
	attr_accessor :temp_dir, :draft_dir
	attr_accessor :draft_index

	def initialize(editor_cmd, temp_dir, draft_dir, options = {})
		@verbose = options[:verbose] ||= false

		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
		@draft_dir = draft_dir

		@draft_index = {}
	end

	def create_draft
		temp_file = Tempfile.new('draft', @temp_dir)
		puts "created temp file #{temp_file.path}\nlaunching editor" if @verbose
		system "#{@launch_editor_cmd} #{temp_file.path}"

		puts "editor closed. File size: #{temp_file.size}" if @verbose
		system "mv #{temp_file.path} #{@draft_dir}" if temp_file.size > 0

		@draft_index[temp_file.path] = {}
	end
end
