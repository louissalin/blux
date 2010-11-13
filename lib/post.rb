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
require 'time'

class Post
	attr_accessor :filename
	attr_reader :creation_time, :published_time, :title

	def initialize(filename, manager, properties = {})
		@filename = filename
		@manager = manager

		@categories = []
		cats = properties['categories']
		if (cats)
			@categories = cats.split(',')
		end

		@creation_time = Time.parse(properties['creation_time']) if properties['creation_time']
		@published_time = Time.parse(properties['published_time']) if properties['published_time']
		@title = properties['title']
	end

	def creation_time=(time)
		@creation_time = time
		@manager.set_attribute(@filename, 'creation_time', time.to_s)
	end

	def published_time=(time)
		@published_time = time
		@manager.set_attribute(@filename, 'published_time', time.to_s)
	end

	def title=(title)
		@title = title
		@manager.set_attribute(@filename, 'title', title)
	end

	def categories
		@categories.join(',')
	end

	def add_category(category)
		if @categories.include?(category) == false
			@categories << category
			@manager.set_attribute(@filename, 'categories', categories)
		end
	end

	def delete_category(category)
		@categories.reject! {|c| c == category}
		@manager.set_attribute(@filename, 'categories', categories)
	end
end
