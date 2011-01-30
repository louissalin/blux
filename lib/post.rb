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

require File.dirname(__FILE__) + '/post_editor.rb'
require File.dirname(__FILE__) + '/repository.rb'

module Blux
	class Post
		attr_accessor :text, :creation_date, :category, :title

		def initialize(text)
			@text = text
			@creation_date = Time.now
			@category = ''
			@title = ''
		end

		def edit
			PostEditor.instance.edit(self)
		end

		def save
			repo = Repository.new
			repo.save(self)
		end

		private
		def get_post_file
			PostFile.new
		end
	end
end
