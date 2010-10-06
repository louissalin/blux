require "#{File.dirname(__FILE__)}/draft_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"
require "#{File.dirname(__FILE__)}/indexer"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_tmp_dir, :draft_dir
	attr_accessor :draft_manager 
	attr_accessor :config
	attr_accessor :index
	attr_accessor :index_file

	include BluxIndexer

	def initialize(draft_manager, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@draft_dir = "#{@blux_dir}/draft"
		@blux_tmp_dir = "#{@blux_dir}/tmp"
		@blux_rc = "#{@home}/.bluxrc"
		@index_file = "#{@blux_dir}/.published"

		@draft_manager = draft_manager
	end

	def start
		unless Dir.exists?(@blux_dir)
			puts "creating #{@blux_dir}\n" if @verbose
			Dir.mkdir(@blux_dir) 
		end

		unless Dir.exists?(@draft_dir)
			puts "creating #{@draft_dir}\n" if @verbose
			Dir.mkdir(@draft_dir) 
		end

		unless Dir.exists?(@blux_tmp_dir)
			puts "creating #{@blux_tmp_dir}\n" if @verbose
			Dir.mkdir(@blux_tmp_dir) 
		end

		load_index
	end

	def load_config
		@config = BluxConfigurationReader.new
		@config.load_config @blux_rc, @verbose

		@draft_manager.setup(@config.launch_editor_cmd, @blux_tmp_dir, @draft_dir, @options)
	end

	def publish(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'

		cmd = "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title} --config #{@blux_rc} | ruby blux.rb --set_edit_url -f #{filename}"
		cmd = cmd + " --verbose" if @verbose

		puts cmd if @verbose
		system cmd
		
		set_attribute(filename, :published_time, Time.now)
	end

	def update(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		url = get_attribute(filename, "edit_url")

		raise "couldn't find an edit url for the draft: #{filename}" unless url 

		cmd = "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title} --update #{url} --config #{@blux_rc}"

		puts cmd if @verbose
		system cmd
		
		set_attribute(filename, :published_time, Time.now)
	end
	
end
