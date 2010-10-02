class BluxConfigurationReader
	attr_reader :launch_editor_cmd, :html_converter_cmd

	def load_config(blux_rc, verbose = false)
		unless File.exists? blux_rc
			puts "creating #{blux_rc}\n" if verbose
			system "touch #{blux_rc}" 
		end

		editor_line = `grep editor: #{blux_rc}`
		editor_match = editor_line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		converter_line = `grep html_converter: #{blux_rc}`
		converter_match = converter_line =~ /^html_converter:\s(.+)$/
		@html_converter_cmd = $1

		puts "editor command: #{@launch_editor_cmd}\n" if verbose
		validate
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			STDERR.puts "please specify an editor in .bluxrc: editor: [your editor of choice]\n"
		end
	end
end
