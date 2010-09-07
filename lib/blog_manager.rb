require "#{File.dirname(__FILE__)}/draft_manager"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_temp_dir
	attr_accessor :launch_editor_cmd
	attr_accessor :draft_manager 

	def initialize(io = STDOUT)
		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@blux_draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"

		@io = io
	end

	def start
		Dir.mkdir(@blux_dir) unless Dir.exists?(@blux_dir)
		Dir.mkdir(@blux_draft_dir) unless Dir.exists?(@blux_draft_dir)
		Dir.mkdir(@blux_tmp_dir) unless Dir.exists?(@blux_tmp_dir)
	end

	def load_config
		system "touch #{@blux_rc}" unless File.exists? @blux_rc

		editor_line = `grep editor: #{@blux_rc}`
		editor_match = editor_line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		validate
	end

	def create_new_draft
		@draft_manager = DraftManager.new(@launch_editor_cmd, @blux_temp_dir)
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			@io << 'please specify an editor in .bluxrc: editor: [your editor of choice]'
		end
	end
end
