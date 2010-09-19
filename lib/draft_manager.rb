require "#{File.dirname(__FILE__)}/IO.rb"
require 'tempfile'
require 'json'
require 'time'

class DraftManager
	include BluxOutput

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
		@io << "created temp file #{temp_file.path}\nlaunching editor\n" if @verbose

		system "#{@launch_editor_cmd} #{temp_file.path}"

		@io << "editor closed. File size: #{temp_file.size}\n" if @verbose
		system "mv #{temp_file.path} #{@draft_dir}" if temp_file.size > 0

		@io << "adding #{temp_file.path} to draft index\n" if @verbose
		@draft_index[temp_file.path] = {:creation_time => Time.now.to_s}
		save_draft_index
	end

	def edit_draft(filename)
		check_filename(filename) do  |draft_filename|
			system "#{@launch_editor_cmd} #{draft_filename}"
			set_attribute(filename, :edited_time => Time.now.to_s)
		end
	end

	def list
		entries = Dir.entries(@draft_dir).reject {|i| i[0] == '.'}
		entries.join("\n")
	end

	def show_info(filename)
		check_index(filename) do |index|
			index.to_json
		end
	end

	def set_attribute(filename, key_val_hash)
		key = key_val_hash.keys[0]
		val = key_val_hash.values[0]

		check_index(filename) do |index|
			index[key.to_s] = val
			save_draft_index
		end
	end

	def get_latest_created_draft
		@draft_index.sort do |a,b| 
			Time.parse(a[1]["creation_time"]) <=> Time.parse(b[1]["creation_time"])
		end[-1][0]
	end

	def delete_attribute(filename, attr_name)
		check_index(filename) do |index|
			index.delete(attr_name.to_s)
			save_draft_index
		end
	end

private
	def check_index(filename)
		check_filename(filename) do
			yield @draft_index[filename]
		end
	end

	def check_filename(filename)
		draft_filename = "#{draft_dir}/#{filename}"

		if (File.exists?(draft_filename))
			yield draft_filename
		else
			@err << "draft filename #{filename} does not exist\n"
		end
	end

	def load_draft_index
		str = ''
		File.open(@draft_index_file, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@draft_index = str.length > 0 ? JSON.parse(str) : {}
	end

	def save_draft_index
		@io << "saving draft index: #{@draft_index.to_json}\n" if @verbose
		File.open(@draft_index_file, 'w') do |f| 
			f.write(@draft_index.to_json) if @draft_index
		end
	end
end
