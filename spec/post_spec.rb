require 'post'

describe Blux::Post, "when creating a new post" do
	it "should initialize an empty post with a creation date of now" do
		time = Time.now
		post = Blux::Post.new

		post.text.should eq('')
		post.creation_date.min.should eq(time.min)
		post.creation_date.hour.should eq(time.hour)
		post.creation_date.day.should eq(time.day)
		post.creation_date.month.should eq(time.month)
		post.creation_date.year.should eq(time.year)
	end
end
