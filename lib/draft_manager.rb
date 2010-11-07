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
	attr_reader :index_file

	include BluxIndexer

	def setup(editor_cmd, temp_dir, draft_dir, options = {})
		@verbose = options[:verbose] ||= false

		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
		@draft_dir = draft_dir
		@index_file = "#{@draft_dir}/.draft_index"

		value = true
		value = system "touch #{@index_file}" unless File.exists? @index_file

		if value
			print_index if @verbose
		else
			msg = 'could not create the draft index file'
			raise RuntimeError, msg
		end
	end

	def create_draft
		temp_file = Tempfile.new('draft', @temp_dir)
		temp_file.close

		if system "#{@launch_editor_cmd} #{temp_file.path}"
			if temp_file.size > 0
				move_temp_file temp_file.path
			end
		else
			msg = "couldn't launch editor with command #{@launch_editor_cmd}"
			raise RuntimeError, msg
		end

		print_index if @verbose
	end
	
	def move_temp_file(tempfile)
		if system "mv #{tempfile} #{@draft_dir}"
			index_key = File.basename(tempfile)
			set_attribute(index_key, "creation_time", Time.now.to_s)
		else
			msg = "failed to move the temp file to the draft folder"
			raise RuntimeError, msg
		end
	end

	def edit_draft(filename)
		check_filename(filename) do  |draft_filename|
			if system "#{@launch_editor_cmd} #{draft_filename}"
				set_attribute(filename, "edited_time", Time.now.to_s)
			else
				msg = "couldn't launch editor with command #{@launch_editor_cmd}"
				raise RuntimeError, msg
			end
		end

		print_index if @verbose
	end

	def delete_draft(filename)
		set_attribute(filename, "deleted", Time.now.to_s)
		print_index if @verbose
	end

	def list
		block = Enumerator.new do |g|
			index = load_index
			index.keys.each do |k|
				g << k if index[k]["deleted"] == nil
			end
		end

		block
	end

	def show_info(filename)
		check_index(filename) do |full_index, index|
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
		ensure_not_deleted filename
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
			index = load_index
			index.reject do |key, val|
				val["deleted"] != nil
			end.sort do |a,b| 
				Time.parse(a[1]["creation_time"]) <=> Time.parse(b[1]["creation_time"])
			end[-1][0]
		end
	end

	def get_draft_by_title(title)
		check_count do
			index = load_index
			index.keys.each do |key|
				draft_title = index[key]["title"]
				return key if draft_title == title
			end
		end
	end
end
