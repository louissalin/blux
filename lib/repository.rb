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

require 'pstore'

module Blux
	class Repository
		STORE_FILE = 'store.db'

		def initialize(location = nil)
			location ||= "#{ENV['HOME']}/.blux"
			unless Dir.exist?(location)
				Dir.mkdir(location)
			end

			@store = PStore.new("#{location}/#{STORE_FILE}")
		end

		def save(post)
			post.id = get_available_id
			@store.transaction do
			end
		end

		private
		def get_available_id
			@store[:posts].length + 1
		end
	end
end
