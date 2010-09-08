require 'tempfile'
require 'json'

class DraftManager
	attr_reader :launch_editor_cmd
	attr_reader :temp_dir, :draft_dir
	attr_reader :draft_index

	def initialize(editor_cmd, temp_dir, draft_dir, options = {})
		@verbose = options[:verbose] ||= false

		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
		@draft_dir = draft_dir
		@draft_index_file = "#{@draft_dir}/.draft_index"

		system "touch #{@draft_index_file}" unless File.exists? @draft_index_file

		load_draft_index
	end

	def create_draft
		temp_file = Tempfile.new('draft', @temp_dir)
		puts "created temp file #{temp_file.path}\nlaunching editor" if @verbose
		system "#{@launch_editor_cmd} #{temp_file.path}"

		puts "editor closed. File size: #{temp_file.size}" if @verbose
		system "mv #{temp_file.path} #{@draft_dir}" if temp_file.size > 0

		puts "adding #{temp_file.path} to draft index" if @verbose
		@draft_index[temp_file.path] = {}
		save_draft_index
	end

private
	def load_draft_index
		str = ''
		File.open(@draft_index_file, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@draft_index = str.length > 0 ? JSON.parse(str) : {}
	end

	def save_draft_index
		puts "saving draft index: #{@draft_index.to_json}" if @verbose
		File.open(@draft_index_file, 'w') do |f| 
			f.write(@draft_index.to_json) if @draft_index
		end
	end
end
