require "#{File.dirname(__FILE__)}/draft_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"

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
		@config = BluxConfigurationReader.new
		@config.load_config @blux_rc, @verbose
	end

	def create_draft_manager
		@draft_manager = DraftManager.new(@launch_editor_cmd, @blux_temp_dir, @blux_draft_dir, @options)
	end

	def publish(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		system "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title}"
	end
end
