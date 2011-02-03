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
require 'singleton'

require File.dirname(__FILE__) + '/config.rb'

module Blux
	class PostEditor
		include Singleton

		def edit(post)
			tf = Tempfile.new('blux')
			tf.puts 'test'
			tf.close

			if system "#{Config.instance.editor_cmd} #{tf.path}"
				tf.open
				post.text = tf.read
			end

		end
	end
end