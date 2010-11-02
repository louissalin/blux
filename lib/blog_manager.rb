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
require 'timeout'

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
		categories = @draft_manager.get_attribute(filename, "categories")

		convert_cmd = "blux --convert -f #{filename}"
		categories_cmd = categories ? "-c \"#{categories}\"" : ""
		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb -t \"#{title}\" --config #{@blux_rc} #{categories_cmd}"
		set_url_cmd = "blux --set_edit_url -f #{filename}"

		cmd = "#{convert_cmd} | #{publish_cmd} | #{set_url_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to publish...") do
			load_index
			set_attribute(filename, :published_time, Time.now)
		end
	end

	def update(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		categories = @draft_manager.get_attribute(filename, "categories")
		url = get_attribute(filename, "edit_url")

		raise "couldn't find an edit url for the draft: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		categories_cmd = categories ? "-c \"#{categories}\"" : ""
		post_cmd = "blux --post-cmd"
		cmd = "blux --convert -f #{filename} | #{publish_cmd} -t \"#{title}\" --update #{url} --config #{@blux_rc} #{categories_cmd} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to update...") do
			set_attribute(filename, :published_time, Time.now)
		end
	end

	def delete(filename)
		url = get_attribute(filename, "edit_url")
		raise "couldn't find an edit url for the draft: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		post_cmd = "blux --post-cmd"
		cmd = "#{publish_cmd} --delete #{url} --config #{@blux_rc} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to delete...") do
			delete_index(filename)
			@draft_manager.delete_draft(filename)
		end
	end

private

	def send_publish_command(cmd, filename, error_msg)
		status = Timeout::timeout(10) { system cmd }
		if status
			yield
		else
			msg = "#{error_msg}\n"
			msg = msg + ' use the --verbose option for more information' if !@verbose

			raise SystemExit, msg
		end

		puts "blog index:\n" if @verbose
		print_index if @verbose
	end
end
