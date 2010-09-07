class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc
	attr_accessor :launch_editor_cmd

	def initialize(io = STDOUT)
		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@blux_rc = "#{@home}/.bluxrc"

		@io = io
	end

	def start
		dir_name = "#{@home}/.blux"
		Dir.mkdir(dir_name) unless Dir.exists?(dir_name)

		draft_dir = "#{dir_name}/drafts"
		Dir.mkdir(draft_dir) unless Dir.exists?(draft_dir)
	end

	def load_config
		system "touch #{@blux_rc}" unless File.exists? @blux_rc

		editor_line = `grep editor: #{@blux_rc}`
		editor_match = editor_line =~ /^editor:\s(.+)$/
		@launch_editor_cmd = $1

		validate
	end

private
	def validate
		if (@launch_editor_cmd == nil)
			@io << 'please specify an editor in .bluxrc: editor: [your editor of choice]'
		end
	end
end
