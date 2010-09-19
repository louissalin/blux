require 'optparse'
require 'ostruct'

class BluxOptionParser
	def self.parse(args)
		options = OpenStruct.new
		options.verbose = false

		opts = OptionParser.new do |opts|
			opts.banner = "Usage: blux command [options]"

			opts.on("-n", "--new", "create a new draft") do 
				options.command = :new
			end
		end

		opts.parse!(args)
		options
	end
end
