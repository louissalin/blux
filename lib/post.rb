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
	attr_accessor :text
	attr_reader :filename, :creation_time, :edited_time, :published_time
	attr_reader :title, :text, :deleted_time, :edit_url

	CREATION_TIME = 'creation_time'
	DELETED_TIME = 'deleted_time'
	PUBLISHED_TIME = 'published_time'
	EDITED_TIME = 'edited_time'
	EDIT_URL = 'edit_url'
	TITLE = 'title'
	CATEGORIES = 'categories'

	def initialize(filename, manager, properties = {})
		@filename = filename
		@manager = manager

		@categories = []
		cats = properties[CATEGORIES]
		if (cats)
			@categories = cats.split(',')
		end

		@creation_time = Time.parse(properties[CREATION_TIME]) if properties[CREATION_TIME]
		@deleted_time = Time.parse(properties[DELETED_TIME]) if properties[DELETED_TIME]
		@published_time = Time.parse(properties[PUBLISHED_TIME]) if properties[PUBLISHED_TIME]
		@edited_time = Time.parse(properties[EDITED_TIME]) if properties[EDITED_TIME]
		@title = properties[TITLE]
	end

	def creation_time=(time)
		@creation_time = time
		@manager.set_attribute(@filename, CREATION_TIME, time.to_s)
	end

	def published_time=(time)
		@published_time = time
		@manager.set_attribute(@filename, PUBLISHED_TIME, time.to_s)
	end

	def edited_time=(time)
		@edited_time = time
		@manager.set_attribute(@filename, EDITED_TIME, time.to_s)
	end

	def title=(title)
		@title = title
		@manager.set_attribute(@filename, TITLE, title)
	end

	def edit_url=(edit_url)
		@edit_url = edit_url
		@manager.set_attribute(@filename, EDIT_URL, edit_url)
	end

	def categories
		@categories.join(',')
	end

	def add_category(category)
		if @categories.include?(category) == false
			@categories << category
			@manager.set_attribute(@filename, CATEGORIES, categories)
		end
	end

	def delete_category(category)
		@categories.reject! {|c| c == category}
		@manager.set_attribute(@filename, CATEGORIES, categories)
	end

	def deleted?
		@deleted_time != nil
	end

	def edit
		@manager.edit_post @filename
	end

	def published?
		@published_time != nil
	end
end
