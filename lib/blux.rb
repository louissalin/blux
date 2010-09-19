require "#{File.dirname(__FILE__)}/blux_option_parser.rb"
require "#{File.dirname(__FILE__)}/blog_manager.rb"

def validate_command(options)
	if (options.command != nil)
		yield options
	else
		STDERR << "No command specified. Possible commands: --new, --edit, --set, --list, --publish"
	end
end

def validate_set_options(options)
	if options.attributes.length.modulo(2) == 0
		yield options.attributes[0], options.attributes[1]
	else
		STDERR << "Attribute error: you must specify an attribute name and a value."
	end
end

def check_filename(options, draft_manager)
	filename = draft_manager.get_latest_created_draft if options.use_latest
	filename = draft_manager.get_draft_by_title(options.title) if options.use_title
	filename = options.filename || filename

	puts "check_filename: #{filename}" if options.verbose
	if filename != nil
		yield filename
	else
		STDERR << "Please specify the draft file you want to work with. If you want to work with the latest created/edited draft, use the --latest option. You can also tell blux to get a draft with a specific title with --title."
	end
end


validate_command(BluxOptionParser.parse(ARGV)) do |options|
	puts "#{options}" if options.verbose

	mgr = BlogManager.new(:verbose => options.verbose)	
	mgr.load_config
	mgr.start

	case options.command
	when :new
		draft_mgr = mgr.create_draft_manager
		draft_mgr.create_draft
	when :edit
		draft_mgr = mgr.create_draft_manager

		check_filename(options, draft_mgr) do |filename|
			draft_mgr.edit_draft filename
		end
	when :list
		draft_mgr = mgr.create_draft_manager
		draft_mgr.list.each do |item|
			puts "#{item}"
			puts "  #{draft_mgr.show_info(item)}" if options.list_details
			puts "  #{draft_mgr.show_preview(item)}" if options.list_preview
		end
	when :set
		draft_mgr = mgr.create_draft_manager

		check_filename(options, draft_mgr) do |filename|
			validate_set_options(options) do |attribute, value|
				draft_mgr.set_attribute(filename, attribute, value)
			end
		end
	end
end

