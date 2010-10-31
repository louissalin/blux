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
require "#{File.dirname(__FILE__)}/draft_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"
require "#{File.dirname(__FILE__)}/indexer"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_tmp_dir, :draft_dir
	attr_accessor :draft_manager 
	attr_accessor :config
	attr_accessor :index
	attr_accessor :index_file

	include BluxIndexer

	def initialize(draft_manager, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"
		@index_file = "#{@blux_dir}/.published"

		@draft_manager = draft_manager
	end

	def start
		unless Dir.exists?(@blux_dir)
			Dir.mkdir(@blux_dir) 
		end

		unless Dir.exists?(@draft_dir)
			Dir.mkdir(@draft_dir) 
		end

		unless Dir.exists?(@blux_tmp_dir)
			Dir.mkdir(@blux_tmp_dir) 
		end

		load_index
		puts "blog index:\n" if @verbose
		print_index if @verbose
	end

	def load_config
		@config = BluxConfigurationReader.new
		@config.load_config @blux_rc, @verbose

		@draft_manager.setup(@config.launch_editor_cmd, @blux_tmp_dir, @draft_dir, @options)
	end

	def publish(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		tags = @draft_manager.get_attribute(filename, "tags")

		convert_cmd = "blux --convert -f #{filename}"
		tags_cmd = tags ? "-c \"#{tags}\"" : ""
		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb -t \"#{title}\" --config #{@blux_rc} #{tags_cmd}"
		set_url_cmd = "blux --set_edit_url -f #{filename}"

		cmd = "#{convert_cmd} | #{publish_cmd} | #{set_url_cmd}"
		cmd = cmd + " --verbose" if @verbose

		if system cmd
			load_index
			set_attribute(filename, :published_time, Time.now)
		else
			msg = "failed to publish...\n"
			msg = msg + ' use the --verbose option for more information' if !@verbose

			raise SystemExit, msg
		end

		puts "blog index:\n" if @verbose
		print_index if @verbose
	end

	def update(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		url = get_attribute(filename, "edit_url")

		raise "couldn't find an edit url for the draft: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		post_cmd = "blux --post-cmd"
		cmd = "blux --convert -f #{filename} | #{publish_cmd} -t \"#{title}\" --update #{url} --config #{@blux_rc} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		if system cmd
			set_attribute(filename, :published_time, Time.now)
		else
			msg = "failed to update...\n"
			msg = msg + ' use the --verbose option for more information' if !@verbose

			raise SystemExit, msg
		end

		puts "blog index:\n" if @verbose
		print_index if @verbose
	end

	def delete(filename)
		url = get_attribute(filename, "edit_url")
		raise "couldn't find an edit url for the draft: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		post_cmd = "blux --post-cmd"
		cmd = "#{publish_cmd} --delete #{url} --config #{@blux_rc} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		if system cmd
			delete_index(filename)
			@draft_manager.delete_draft(filename)
		else
			msg = "failed to delete...\n"
			msg = msg + ' use the --verbose option for more information' if !@verbose

			raise SystemExit, msg
		end

		puts "blog index:\n" if @verbose
		print_index if @verbose
	end
end
