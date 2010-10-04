require 'optparse'
require 'ostruct'

class BluxOptionParser
	def self.parse(args)
		options = OpenStruct.new
		options.verbose = false
		options.list_preview = false
		options.list_details = false

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: blux <command> [options] [attributes]"

			opts.on("-n", "--new", "create a new draft") do 
				options.command = :new
			end

			opts.on("-e", "--edit", "edit a draft") do
				options.command = :edit
			end

			opts.on("-l", "--list", "list drafts") do
				options.command = :list
			end

			opts.on("-s", "--set", "set an attribute on a draft") do
				options.command = :set
			end

			opts.on("-c", "--convert", "convert a draft to html") do
				options.command = :convert
			end

			opts.on("-o", "--out", "dump the content of a draft to stdout") do
				options.command = :out
			end

			opts.on("-p", "--publish", "publish a draft") do
				options.command = :publish
			end

			opts.on("--latest", "apply the selected command to the latest draft") do
				options.use_latest = true
			end

			opts.on("--title TITLE", "apply the selected command to a draft with a specific title") do |title|
				options.use_title = true
				options.title = title
			end

			opts.on("-f", "--file FILENAME", "apply the selected command to a specific draft file") do |filename|
				options.filename = filename
			end

			opts.on("--set_id", "sets a unique ID, normally given through a publisher") do
				options.command = :set_id
			end

			opts.on("--with-preview", "show a preview of each draft while listing") do
				options.list_preview = true
			end

			opts.on("--details", "show all attributes when listing") do
				options.list_details = true
			end

			opts.on("--verbose", "verbose mode") do
				options.verbose = true
			end
		end

		opts.parse!(args)

		options.attributes = args
		options
	end
end
