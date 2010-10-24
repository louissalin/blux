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
module BluxIndexer
	def check_index(filename)
		check_filename(filename) do
			@index[filename] ||= {}
			yield @index[filename]
		end
	end

	def check_filename(filename)
		draft_filename = "#{self.draft_dir}/#{filename}"

		if (File.exists?(draft_filename))
			yield draft_filename
		else
			msg = "draft filename #{filename} does not exist"
			raise RuntimeError, msg
		end
	end

	def check_title(filename, attr_key, attr_val)
		return true unless attr_key.to_s == "title"
		
		unique_title = true
		@index.keys.reject{|k| k == filename}.each do |key|
			unique_title = false if (@index[key][attr_key.to_s] == attr_val)
		end
		
		STDERR << "warning: title '#{attr_val}' is not unique\n" unless unique_title 
		unique_title
	end

	def set_attribute(filename, key, val)
		check_index(filename) do |index|
			if check_title(filename, key, val)
				index[key.to_s] = val 
				save_index
			end
		end
	end

	def delete_attribute(filename, attr_name)
		check_index(filename) do |index|
			index.delete(attr_name.to_s)
			save_index
		end
	end

	def get_attribute(filename, attribute)
		check_index(filename) do |index|
			index[attribute]
		end
	end

	def check_count
		if @index.keys.length > 0
			yield
		else
			msg = "there is currently no saved index"
			raise RuntimeError, msg
		end
	end

	def load_index
		system "touch #{@index_file}" unless File.exists? @index_file

		str = ''
		File.open(@index_file, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@index = str.length > 0 ? JSON.parse(str) : {}
	end

	def save_index
		File.open(@index_file, 'w') do |f| 
			f.write(@index.to_json) if @index
		end
	end

	def print_index
		puts @index.to_json + "\n" if @verbose
	end
end
