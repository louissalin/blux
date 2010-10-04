require "#{File.dirname(__FILE__)}/draft_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_tmp_dir, :blux_draft_dir
	attr_accessor :draft_manager 
	attr_accessor :config
	attr_accessor :published_posts

	def initialize(draft_manager, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@blux_draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"
		@blux_published = "#{@blux_dir}/.published"

		@draft_manager = draft_manager
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

		load_published
	end

	def load_config
		@config = BluxConfigurationReader.new
		@config.load_config @blux_rc, @verbose

		@draft_manager.setup(@config.launch_editor_cmd, @blux_tmp_dir, @blux_draft_dir, @options)
		puts @draft_manager
	end

	def publish(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		system "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title} --config #{@blux_rc}"
		
		@published_posts[filename] = {}
	end
	
	def load_published
		puts "creating #{@blux_published}\n" if @verbose
		system "touch #{@blux_published}" unless File.exists? @blux_published

		str = ''
		File.open(@blux_published, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@published_posts = str.length > 0 ? JSON.parse(str) : {}
	end
end
