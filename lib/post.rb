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
require 'json'
require 'time'

require "#{File.dirname(__FILE__)}/indexer"

class Post
	attr_accessor :filename
	attr_accessor :creation_time

	def initialize(filename)
		@filename = filename
	end
end
