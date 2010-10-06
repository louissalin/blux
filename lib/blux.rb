#!/usr/bin/env ruby

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

def check_filename(options, blog_manager)
	filename = blog_manager.draft_manager.get_latest_created_draft if options.use_latest
	filename = blog_manager.draft_manager.get_draft_by_title(options.title) if options.use_title
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

	draft_manager = DraftManager.new
	mgr = BlogManager.new(draft_manager, :verbose => options.verbose)	
	mgr.load_config
	mgr.start

	case options.command
	when :new
		mgr.draft_manager.create_draft
	when :edit
		check_filename(options, mgr) do |filename|
			mgr.draft_manager.edit_draft filename
		end
	when :list
		mgr.draft_manager.list.each do |item|
			break if options.filename != nil && options.filename != item
			puts "#{item}"
			puts "  #{mgr.draft_manager.show_info(item)}" if options.list_details
			puts "  #{mgr.draft_managershow_preview(item)}" if options.list_preview
		end
	when :set
		check_filename(options, mgr) do |filename|
			validate_set_options(options) do |attribute, value|
				draft_mgr.set_attribute(filename, attribute, value)
			end
		end
	when :out
		check_filename(options, mgr) do |filename|
			STDOUT.puts(mgr.draft_manager.output filename)
		end
	when :convert
		check_filename(options, mgr) do |filename|
			system "ruby blux.rb --out -f #{filename} | #{mgr.config.html_converter_cmd}"
		end
	when :publish
		check_filename(options, mgr) do |filename|
			puts "publishing" if options.verbose
			mgr.publish filename
		end
	when :update
		check_filename(options, mgr) do |filename|
			puts "updating" if options.verbose
			mgr.update filename
		end
	when :set_edit_url
		check_filename(options, mgr) do |filename|
			ARGF.each do |url|
				mgr.draft_manager.set_attribute(filename, 'edit_url', url.strip)
			end
		end
	end
end

