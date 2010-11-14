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
require "#{File.dirname(__FILE__)}/post_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"
require "#{File.dirname(__FILE__)}/indexer"
require 'timeout'

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_tmp_dir, :post_dir
	attr_accessor :post_manager 
	attr_accessor :config

	include BluxIndexer

	def initialize(post_manager, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@post_dir = "#{@blux_dir}/post"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"

		@post_manager = post_manager
	end

	def start
		unless Dir.exists?(@blux_dir)
			Dir.mkdir(@blux_dir) 
		end

		unless Dir.exists?(@post_dir)
			Dir.mkdir(@post_dir) 
		end

		unless Dir.exists?(@blux_tmp_dir)
			Dir.mkdir(@blux_tmp_dir) 
		end
	end

	def load_config
		@config = BluxConfigurationReader.new
		@config.load_config @blux_rc, @verbose

		@post_manager.setup(@config.launch_editor_cmd, @blux_tmp_dir, @post_dir, @options)
	end

	def publish(post)
		raise "this post has already been published" if post.published?

		filename = post.filename
		title = post.title
		categories = post.categories

		convert_cmd = "blux --convert -f #{filename}"
		categories_cmd = categories ? "-c \"#{categories}\"" : ""
		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb -t \"#{title}\" --config #{@blux_rc} #{categories_cmd}"
		set_url_cmd = "blux --set_edit_url -f #{filename}"

		cmd = "#{convert_cmd} | #{publish_cmd} | #{set_url_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to publish...") do
			@post_manager.set_attribute(filename, "published_time", Time.now)
		end
	end

	def update(post)
		filename = post.filename
		title = post.title
		categories = post.categories
		url = post.edit_url

		raise "couldn't find an edit url for the post: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		categories_cmd = categories ? "-c \"#{categories}\"" : ""
		post_cmd = "blux --post-cmd"
		cmd = "blux --convert -f #{filename} | #{publish_cmd} -t \"#{title}\" --update #{url} --config #{@blux_rc} #{categories_cmd} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to update...") do
			@post_manager.set_attribute(filename, "published_time", Time.now)
		end
	end

	def delete(post)
		filename = post.filename
		url = post.edit_url

		raise "couldn't find an edit url for the post: #{filename}" unless url 

		publish_cmd = "ruby #{File.dirname(__FILE__)}/publishing/wp_publish.rb"
		post_cmd = "blux --post-cmd"
		cmd = "#{publish_cmd} --delete #{url} --config #{@blux_rc} | #{post_cmd}"
		cmd = cmd + " --verbose" if @verbose

		send_publish_command(cmd, filename, "failed to delete...") do
			@post_manager.delete_post(filename)
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
	end
end
