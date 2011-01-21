#!/usr/bin/env ruby
#
# Copyright 2011 Louis-Philippe Salin de l'Etoile, aka Louis Salin
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
require 'config'

module Blux
	class PostEditor
		def edit(post)
			tmp_file = Tempfile.new('blux')

			File.open(tmp_file.path, 'w') do |file|
				file.puts post.text
			end

			system "#{Config.instance.editor_cmd} #{tmp_file.path}"
		end
	end
end
