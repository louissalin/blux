#
# Copyright 2010 Louis-Philippe Salin de l'Etoile, aka Louis Salin
# email: louis.phil@gmail.com
#
# This file is part of Blux.
#
# Blux is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Blux is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Blux.  If not, see <http://www.gnu.org/licenses/>.
require 'tempfile'
require 'json'
require 'time'

require "#{File.dirname(__FILE__)}/indexer"

class DraftManager
	attr_reader :launch_editor_cmd
	attr_reader :temp_dir, :draft_dir
	attr_reader :index

	include BluxIndexer

	def setup(editor_cmd, temp_dir, draft_dir, options = {})
		@verbose = options[:verbose] ||= false

		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
		@draft_dir = draft_dir
		@index_file = "#{@draft_dir}/.draft_index"

		system "touch #{@index_file}" unless File.exists? @index_file

		load_index
	end

	def create_draft
		temp_file = Tempfile.new('draft', @temp_dir)
		temp_file.close

		puts "created temp file #{temp_file.path}\nlaunching editor\n" if @verbose

		system "#{@launch_editor_cmd} #{temp_file.path}"

		puts "editor closed. File size: #{temp_file.size}\n" if @verbose
		if temp_file.size > 0
			system "mv #{temp_file.path} #{@draft_dir}"

			index_key = File.basename(temp_file.path)
			puts "adding #{index_key} to draft index\n" if @verbose
			@index[index_key] = {:creation_time => Time.now.to_s}
			save_index
		end
	end

	def edit_draft(filename)
		puts "editing draft #{filename}" if @verbose

		check_filename(filename) do  |draft_filename|
			puts "editing: #{@launch_editor_cmd} #{draft_filename}" if @verbose

			system "#{@launch_editor_cmd} #{draft_filename}"
			set_attribute(filename, "edited_time", Time.now.to_s)
		end
	end

	def list
		Dir.entries(@draft_dir).reject {|i| i[0] == '.'}
	end

	def show_info(filename)
		check_index(filename) do |index|
			index.to_json
		end
	end

	def show_preview(filename)
		check_filename(filename) do |draft_filename|
			File.open(draft_filename, 'r') do |f|
				if f.eof?
					''
				else
					line = f.readline.gsub("\n", '')
					line.length > 76 ? line[0..75] + '...' : line
				end
			end
		end
	end

	def output(filename)
		check_filename(filename) do |draft_filename|
			File.open(draft_filename, 'r') do |f|
				if f.eof?
					''
				else
					text = ''
					f.each do |l|
						text += l
					end

					text
				end
			end
		end
	end

	def get_latest_created_draft
		check_count do
			@index.sort do |a,b| 
				Time.parse(a[1]["creation_time"]) <=> Time.parse(b[1]["creation_time"])
			end[-1][0]
		end
	end

	def get_draft_by_title(title)
		check_count do
			@index.keys.each do |key|
				draft_title = @index[key]["title"]
				return key if draft_title == title
			end
		end
	end
end
