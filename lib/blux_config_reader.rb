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
class BluxConfigurationReader
	attr_reader :launch_editor_cmd, :html_converter_cmd
	attr_reader :blog, :author_name, :user_name, :password

	def load_config(blux_rc, verbose = false)
		unless File.exists? blux_rc
			puts "creating #{blux_rc}\n" if verbose
			system "touch #{blux_rc}" 
		end

		line = `grep editor: #{blux_rc}`
		match = line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		line = `grep html_converter: #{blux_rc}`
		match = line =~ /^html_converter:\s(.+)$/
		@html_converter_cmd = $1

		line = `grep blog: #{blux_rc}`
		match = line =~ /^blog:\s(.+)$/
		@blog = $1

		line = `grep author_name: #{blux_rc}`
		match = line =~ /^author_name:\s(.+)$/
		@author_name = $1

		line = `grep user_name: #{blux_rc}`
		match = line =~ /^user_name:\s(.+)$/
		@user_name = $1

		line = `grep password: #{blux_rc}`
		match = line =~ /^password:\s(.+)$/
		@password = $1

		puts "editor command: #{@launch_editor_cmd}\n" if verbose
		validate
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			STDERR.puts "please specify an editor in .bluxrc: editor: [your editor of choice]\n"
		end

		if (@html_converter_cmd == nil)
			STDERR.puts "please specify an html converter in .bluxrc: html_converter: [your converter command of choice]\n"
		end

		if (@blog == nil)
			STDERR.puts "please specify your wordpress blog name in .bluxrc: blog: [your blog]\n"
		end

		if (@author_name == nil)
			STDERR.puts "please specify an author name in .bluxrc: author_name: [your name]\n"
		end

		if (@user_name == nil)
			STDERR.puts "please specify your wordpress user name in .bluxrc: user_name: [your user name]\n"
		end

		if (@password == nil)
			STDERR.puts "please specify your wordpress password in .bluxrc: password: [your password]\n"
		end
	end
end
