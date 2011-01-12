module Blux
	class Post
		attr_reader :text, :creation_date

		def initialize
			@text = ''
			@creation_date = Time.now
		end
	end
end
