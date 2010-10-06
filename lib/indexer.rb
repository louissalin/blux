module BluxIndexer
	def check_index(filename)
		check_filename(filename) do
			yield @index[filename]
		end
	end

	def check_filename(filename)
		draft_filename = "#{@draft_dir}/#{filename}"

		if (File.exists?(draft_filename))
			yield draft_filename
		else
			STDERR.puts "draft filename #{filename} does not exist\n"
		end
	end

	def check_title(filename, attr_key, attr_val)
		return true unless attr_key.to_s == "title"
		
		unique_title = true
		@index.keys.reject{|k| k == filename}.each do |key|
			unique_title = false if (@index[key][attr_key.to_s] == attr_val)
		end
		
		STDERR.puts "title '#{attr_val}' is not unique\n" unless unique_title 
		unique_title
	end

	def set_attribute(filename, key, val)
		check_index(filename) do |index|
			if check_title(filename, key, val)
				puts "setting attribute #{key} to #{val} in index #{@index_file}" if @verbose
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
			STDERR.puts "there is currently no saved index\n"
		end
	end

	def load_index
		puts "creating #{@index_file}\n" if @verbose
		system "touch #{@index_file}" unless File.exists? @index_file

		str = ''
		File.open(@index_file, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@index = str.length > 0 ? JSON.parse(str) : {}
	end

	def save_index
		puts "saving index: #{@index.to_json}\n" if @verbose
		File.open(@index_file, 'w') do |f| 
			f.write(@index.to_json) if @index
		end
	end
end
