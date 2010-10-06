require "#{File.dirname(__FILE__)}/draft_manager"
require "#{File.dirname(__FILE__)}/blux_config_reader"
require "#{File.dirname(__FILE__)}/indexer"

class BlogManager
	attr_accessor :home, :blux_dir, :blux_rc, :blux_tmp_dir, :draft_dir
	attr_accessor :draft_manager 
	attr_accessor :config
	attr_accessor :index

	include BluxIndexer

	def initialize(draft_manager, options = {})
		@options = options
		@verbose = options[:verbose] ||= false

		@home = ENV['HOME']
		@blux_dir = "#{@home}/.blux"
		@draft_dir = "#{@blux_dir}/draft"
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

		unless Dir.exists?(@draft_dir)
			puts "creating #{@draft_dir}\n" if @verbose
			Dir.mkdir(@draft_dir) 
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

		@draft_manager.setup(@config.launch_editor_cmd, @blux_tmp_dir, @draft_dir, @options)
	end

	def publish(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'

		cmd = "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title} --config #{@blux_rc} | ruby blux.rb --set_edit_url -f #{filename}"
		cmd = cmd + " --verbose" if @verbose

		puts cmd if @verbose
		system cmd
		
		@index[filename] = {"published_time" => Time.now}
		save_published_index
	end

	def update(filename)
		title = @draft_manager.get_attribute(filename, "title") || 'no title'
		id = @draft_manager.get_attribute(filename, "id")

		raise "couldn't find an id for the draft: #{filename}" unless id

		cmd = "ruby blux.rb --convert -f #{filename} | ruby wp_publish.rb -t #{title} --update #{id} --config #{@blux_rc}"

		puts cmd if @verbose
		system cmd
		
		@index[filename] = {"published_time" => Time.now}
		save_published_index
	end
	
	def load_published
		puts "creating #{@blux_published}\n" if @verbose
		system "touch #{@blux_published}" unless File.exists? @blux_published

		str = ''
		File.open(@blux_published, 'r') do |f| 
			f.each_line {|l| str += l}
		end
			
		@index = str.length > 0 ? JSON.parse(str) : {}
	end

private
	def save_published_index
		puts "saving published draft index: #{@index.to_json}\n" if @verbose
		File.open(@blux_published, 'w') do |f| 
			f.write(@index.to_json) if @index
		end
	end
end
