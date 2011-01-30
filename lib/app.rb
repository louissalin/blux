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

require File.dirname(__FILE__) + '/config.rb'
require File.dirname(__FILE__) + '/post.rb'

module Blux
	class App
		attr_reader :current_post

		def initialize
			ConfigReader.new.read_config
		end

		def create_new_post
			@current_post = Post.new('')
			@current_post.edit
			@current_post.save
		end
	end
end
