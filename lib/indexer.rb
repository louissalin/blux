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
			full_index = load_index
			full_index[filename] ||= {}
			yield full_index, full_index[filename]
		end
	end
	
	def check_filename(filename)
		post_filename = "#{self.post_dir}/#{filename}"

		if (File.exists?(post_filename))
			yield post_filename
		else
			msg = "post filename #{filename} does not exist"
			raise RuntimeError, msg
		end
	end

	def set_attribute(filename, key, val)
		check_index(filename) do |full_index, index|
			case key
			when "title"
				unique_title = true
				full_index.keys.reject{|k| k == filename}.each do |other_key|
					unique_title = false if (full_index[other_key.to_s][key] == val)
				end

				STDERR << "warning: title '#{val}' is not unique\n" unless unique_title 

				index[key.to_s] = val 
			when "categories"
				values = Array.new
				values << index[key.to_s] unless index[key.to_s] == nil
				values << val

				index[key.to_s] = values.join(',')
			else
				index[key.to_s] = val 
			end

			save_index(full_index)
		end
	end

	def delete_attribute(filename, attr_name)
		check_index(filename) do |full_index, index|
			case attr_name
			when "categories"
				if block_given?
					categories = yield 
					categories_to_remove = categories.split(',')

					values = index[attr_name.to_s].split(',')

					new_values = values.reject{|i| categories_to_remove.include?(i)}.join(',')
					
					if new_values.length > 0
						index[attr_name.to_s] = new_values
					else
						index.delete(attr_name.to_s)
					end
				else
					index.delete(attr_name.to_s)
				end
			else
				index.delete(attr_name.to_s)
			end

			save_index(full_index)
		end
	end

	def get_attribute(filename, attribute)
		check_index(filename) do |full_index, index|
			index[attribute]
		end
	end

	def check_count
		index = load_index
		if index.keys.length > 0
			yield
		else
			msg = "there is currently no saved index"
			raise RuntimeError, msg
		end
	end
	
	def delete_index(filename)
		index = load_index
		save_index if index.delete filename
	end

	def load_index
		system "touch #{@index_file}" unless File.exists? @index_file

		str = ''
		File.open(@index_file, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		return str.length > 0 ? JSON.parse(str) : {}
	end

	def save_index(index)
		File.open(@index_file, 'w') do |f| 
			f.write(index.to_json) if index
		end
	end

	def print_index
		index = load_index
		puts index.to_json + "\n" if @verbose
	end

	def ensure_not_deleted(filename) 
		check_index(filename) do |full_index, index|
			msg = "post filename #{filename} has been deleted"
			raise RuntimeError, msg if index["deleted"] 
		end
	end
end
