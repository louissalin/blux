module Blux
	class Post
		attr_accessor :text, :creation_date, :category, :title

		def initialize(text)
			@text = text
			@creation_date = Time.now
			@category = ''
			@title = ''
		end
	end
end
