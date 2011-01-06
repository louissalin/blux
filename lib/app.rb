require 'config'

module Blux
	class App
		def initialize
			ConfigReader.new.read_config
		end
	end
end
