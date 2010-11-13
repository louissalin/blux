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
require "#{File.dirname(__FILE__)}/post"

class PostManager
	attr_reader :launch_editor_cmd
	attr_reader :temp_dir, :post_dir

	include BluxIndexer

	def setup(editor_cmd, temp_dir, post_dir, options = {})
		@verbose = options[:verbose] ||= false

		@launch_editor_cmd = editor_cmd
		@temp_dir = temp_dir
		@post_dir = post_dir
		@index_file = "#{@post_dir}/.post_index"

		value = true
		value = system "touch #{@index_file}" unless File.exists? @index_file

		if value
			print_index if @verbose
		else
			msg = 'could not create the post index file'
			raise RuntimeError, msg
		end
	end

	def create_post
		temp_file = Tempfile.new('post', @temp_dir)
		temp_file.close

		post = nil
		if system "#{@launch_editor_cmd} #{temp_file.path}"
			if temp_file.size > 0
				move_temp_file temp_file.path
				filename = File.basename(temp_file.path)

				post = Post.new(filename, self)
				post.creation_time = Time.now
			end
		else
			msg = "couldn't launch editor with command #{@launch_editor_cmd}"
			raise RuntimeError, msg
		end

		print_index if @verbose
		post
	end

	def get_post(filename)
		post = load_post(filename)
		ensure_not_deleted(post)

		post
	end
	
	def move_temp_file(tempfile)
		unless system "mv #{tempfile} #{@post_dir}"
			msg = "failed to move the temp file to the post folder"
			raise RuntimeError, msg
		end
	end

	def edit_post(filename)
		check_filename(filename) do  |post_filename|
			if system "#{@launch_editor_cmd} #{post_filename}"
				set_attribute(filename, "edited_time", Time.now.to_s)
			else
				msg = "couldn't launch editor with command #{@launch_editor_cmd}"
				raise RuntimeError, msg
			end
		end

		print_index if @verbose
	end

	def delete_post(filename)
		set_attribute(filename, Post::DELETED_TIME, Time.now.to_s)
		print_index if @verbose
	end

	def list
		block = Enumerator.new do |g|
			index = load_index
			index.keys.each do |k|
				g << k if index[k][Post::DELETED_TIME] == nil
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
		check_filename(filename) do |post_filename|
			File.open(post_filename, 'r') do |f|
				if f.eof?
					''
				else
					line = f.readline.gsub("\n", '')
					line.length > 76 ? line[0..75] + '...' : line
				end
			end
		end
	end

	def get_latest_created_post
		check_count do
			index = load_index
			non_deleted_posts = index.reject do |key, val|
									val[Post::DELETED_TIME] != nil
								end

			sorted = non_deleted_posts.sort do |a,b| 
						 Time.parse(a[1][Post::CREATION_TIME]) <=> Time.parse(b[1][Post::CREATION_TIME])
					 end[-1]

			latest = sorted[0]
			get_post(latest)
		end
	end

	def get_post_by_title(title)
		check_count do
			index = load_index
			index.keys.each do |key|
				post_title = index[key][Post::TITLE]
				return get_post(key) if post_title == title
			end
		end
	end

	private

	def output(filename)
		check_filename(filename) do |post_filename|
			File.open(post_filename, 'r') do |f|
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

	def ensure_not_deleted(post) 
		msg = "post filename #{post.filename} has been deleted"
		raise RuntimeError, msg if post.deleted?
	end

	def load_post(filename)
		check_index(filename) do |index, properties|
			post = Post.new(filename, self, properties)
			post.text = output(filename)
			post
		end
	end
end
