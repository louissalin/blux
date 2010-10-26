#
# Copyright 2010 Louis-Philippe Salin de l'Etoile, aka Louis Salin
# Copyright (c) 2007 John Mettraux
#
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
require 'optparse'
require 'ostruct'

class WPOptionParser
	def self.parse(args)
		options = OpenStruct.new
		options.tags = []
		options.title = nil
		options.type = 'html'
		options.bluxrc = nil
		options.command = :post
		options.entry_id = nil

		opts = OptionParser.new
		opts.banner = "Usage: post.rb [options]"
		opts.separator ""
		opts.separator "options :"

		opts.on("-c", "--categories {list}", "comma separated list of tags/categories") do |v|
			options.tags = v.split ","
		end

		opts.on("-t", "--title {title}", "title for the post") do |v|
			options.title = v
		end

		opts.on("-T", "--type {html|xhtml|text}", 
				"type of the content. ('html' is the default).") do |v|
			options.type = v
			end

		opts.on("--config {config_file}", "blux config file path") do |f|
			options.bluxrc = f
		end

		opts.on("--update {entry_id}", "update an existing post") do |id|
			options.command = :put
			options.entry_id = id
		end

		opts.on("--delete {entry_id}", "delete an existing post") do |id|
			options.command = :delete
			options.entry_id = id
		end

		opts.on("-h", "--help",	"displays this help") do
			puts
			puts opts.to_s
			puts
			exit 0
		end

		opts.parse!(args)
		options
	end
end
