require 'repository'
require 'post'

describe Blux::Repository, "when creating an instance of the repository" do
	before :each do
		@blux_dir = "#{ENV['HOME']}/.blux"

		pstore = mock('pstore')
		PStore.stub(:new).and_return(pstore)
	end

	it "should create the .blux directory in ~ if it doesn't exist" do
		Dir.stub(:exist?).with('test').and_return(false)

		Dir.should_receive(:mkdir).with('test')
		Blux::Repository.new('test')
	end

	it "should not create the .blux directory if it exists" do
		Dir.stub(:exist?).with(@blux_dir).and_return(true)

		Dir.should_not_receive(:mkdir).with(@blux_dir)
		Blux::Repository.new(@blux_dir)
	end

	it "should default the location to ~/.blux" do
		Dir.stub(:exist?).with(@blux_dir).and_return(false)

		Dir.should_receive(:mkdir).with(@blux_dir)
		Blux::Repository.new
	end
end

describe Blux::Repository, "when saving the first post" do
	it "should assign a new id of 1" do
		pstore = mock('pstore')
		PStore.stub(:new).and_return(pstore)
		pstore.stub(:transaction)
		pstore.stub(:[]).with(:posts).and_return([])

		blux_dir = "#{ENV['HOME']}/.blux"
		Dir.stub(:exist?).with(blux_dir).and_return(true)
		repo = Blux::Repository.new(blux_dir)

		post = Blux::Post.new('test')
		repo.save(post)

		post.id.should eq(1)
	end
end

describe Blux::Repository, "when saving a post" do
	it "should assign a new id incrementally" do
		pstore = mock('pstore')
		PStore.stub(:new).and_return(pstore)
		pstore.stub(:transaction)
		pstore.stub(:[]).with(:posts).and_return([1, 2])

		blux_dir = "#{ENV['HOME']}/.blux"
		Dir.stub(:exist?).with(blux_dir).and_return(true)
		repo = Blux::Repository.new(blux_dir)

		post = Blux::Post.new('test')
		repo.save(post)

		post.id.should eq(3)
	end
end

describe Blux::Repository, "when saving a post after having deleted one" do
	it "should assign the 1st available id" do
		# do math n(n+1)/2 to find a whole, or inc by one if not found
	end
end
