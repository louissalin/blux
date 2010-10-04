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
end
