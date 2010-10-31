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
require 'optparse'
require 'ostruct'

class BluxOptionParser
	def self.parse(args)
		options = OpenStruct.new
		options.verbose = false
		options.list_preview = false
		options.list_details = false

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: blux <command> [options] [attributes]"

			opts.on("-n", "--new", "create a new draft") do 
				options.command = :new
			end

			opts.on("-e", "--edit", "edit a draft") do
				options.command = :edit
			end

			opts.on("-l", "--list", "list drafts") do
				options.command = :list
			end

			opts.on("-s", "--set", "set an attribute on a draft") do
				options.command = :set
			end
			
			opts.on("--unset ATTR", "delete an attribute on a draft") do |attr|
				options.command = :unset
				options.attribute = attr
			end

			opts.on("-c", "--convert", "convert a draft to html") do
				options.command = :convert
			end

			opts.on("-o", "--out", "dump the content of a draft to stdout") do
				options.command = :out
			end

			opts.on("-p", "--publish", "publish a draft") do
				options.command = :publish
			end

			opts.on("-u", "--update", "update a draft") do
				options.command = :update
			end

			opts.on("-d", "--delete", "mark a draft as deleted") do
				options.command = :delete
			end

			opts.on("--latest", "work on the latest draft") do
				options.use_latest = true
			end

			opts.on("--title TITLE", "work on a draft with title") do |title|
				options.use_title = true
				options.title = title
			end

			opts.on("-f", "--file FILENAME", "work on a specific draft file") do |filename|
				options.filename = filename
			end

			opts.on("--set_edit_url", "sets the edit url, given after publishing") do
				options.command = :set_edit_url
			end

			opts.on("--post-cmd", "shows post publishing info: request & response") do
				options.command = :show_post_info
			end

			opts.on("--with-preview", "show a preview of each draft while listing") do
				options.list_preview = true
			end

			opts.on("--details", "show all attributes when listing") do
				options.list_details = true
			end

			opts.on("--verbose", "verbose mode") do
				options.verbose = true
			end

			opts.on("--version", "print version information") do
				options.command = :version
			end

			opts.on_tail("-h", "--help", "show this message") do
				puts opts
				exit
			end
		end

		opts.parse!(args)

		options.attributes = args
		options
	end
end
