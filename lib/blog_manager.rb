require "#{File.dirname(__FILE__)}/draft_manager"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_temp_dir
	attr_accessor :launch_editor_cmd, :html_converter_cmd
	attr_accessor :draft_manager 

	def initialize(options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@blux_draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"
	end

	def start
		unless Dir.exists?(@blux_dir)
			puts "creating #{@blux_dir}\n" if @verbose
			Dir.mkdir(@blux_dir) 
		end

		unless Dir.exists?(@blux_draft_dir)
			puts "creating #{@blux_draft_dir}\n" if @verbose
			Dir.mkdir(@blux_draft_dir) 
		end

		unless Dir.exists?(@blux_tmp_dir)
			puts "creating #{@blux_tmp_dir}\n" if @verbose
			Dir.mkdir(@blux_tmp_dir) 
		end
	end

	def load_config
		unless File.exists? @blux_rc
			puts "creating #{@blux_rc}\n" if @verbose
			system "touch #{@blux_rc}" 
		end

		editor_line = `grep editor: #{@blux_rc}`
		editor_match = editor_line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		converter_line = `grep html_converter: #{@blux_rc}`
		converter_match = converter_line =~ /^html_converter:\s(.+)$/
		@html_converter_cmd = $1

		puts "editor command: #{@launch_editor_cmd}\n" if @verbose
		validate
	end

	def create_draft_manager
		@draft_manager = DraftManager.new(@launch_editor_cmd, @blux_temp_dir, @blux_draft_dir, @options)
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			STDERR.puts "please specify an editor in .bluxrc: editor: [your editor of choice]\n"
		end
	end
end
