require 'optparse'
require 'ostruct'

class BluxOptionParser
	def self.parse(args)
		options = OpenStruct.new
		options.verbose = false

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

			opts.on("--verbose", "verbose mode") do
				options.verbose = true
			end
		end

		opts.parse!(args)

		options.attributes = args
		options
	end
end
