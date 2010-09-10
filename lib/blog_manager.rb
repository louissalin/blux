require "#{File.dirname(__FILE__)}/draft_manager"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_temp_dir
	attr_accessor :launch_editor_cmd
	attr_accessor :draft_manager 

	def initialize(io = STDOUT, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@blux_draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"

		@io = io
	end

	def start
		unless Dir.exists?(@blux_dir)
			puts "creating #{@blux_dir}" if @verbose
			Dir.mkdir(@blux_dir) 
		end

		unless Dir.exists?(@blux_draft_dir)
			puts "creating #{@blux_draft_dir}" if @verbose
			Dir.mkdir(@blux_draft_dir) 
		end

		unless Dir.exists?(@blux_tmp_dir)
			puts "creating #{@blux_tmp_dir}" if @verbose
			Dir.mkdir(@blux_tmp_dir) 
		end
	end

	def load_config
		unless File.exists? @blux_rc
			puts "creating #{@blux_rc}" if @verbose
			system "touch #{@blux_rc}" 
		end

		editor_line = `grep editor: #{@blux_rc}`
		editor_match = editor_line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		puts "editor command: #{@launch_editor_cmd}" if @verbose
		validate
	end

	def create_draft_manager
		@draft_manager = DraftManager.new(@launch_editor_cmd, @blux_temp_dir, @blux_draft_dir, @io, @options)
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			@io << 'please specify an editor in .bluxrc: editor: [your editor of choice]'
		end
	end
end
