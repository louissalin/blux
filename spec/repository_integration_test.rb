require 'repository'
require 'post'

describe Blux::Repository, "when saving a post" do
	it "should save the post" do
		store_location = File.dirname(__FILE__)
		store_file = store_location + Blux::Repository::STORE_FILE

		repo = Blux::Repository.new(store_location)

		post = Blux::Post.new('test')
		post.creation_date = Time.now
		post.category = 'category1'
		post.title = 'Dude'

		repo.save(post)

		File.delete(store_file) if File.exist?(store_file)
	end
end
