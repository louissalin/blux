class BlogManager
	attr_accessor :home

	def initialize
		@home = ENV['HOME']
	end
end
