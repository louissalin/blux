module RepositoryTestSetup
	def setup_pstore_mock(*expected_post_ids)
		pstore = mock('pstore')
		PStore.stub(:new).and_return(pstore)
		pstore.stub(:transaction)
		pstore.stub(:[]).with(:posts).and_return(expected_post_array(expected_post_ids))

		save_a_post
	end

	def save_a_post
		blux_dir = "#{ENV['HOME']}/.blux"
		Dir.stub(:exist?).with(blux_dir).and_return(true)
		repo = Blux::Repository.new(blux_dir)

		@post = Blux::Post.new('test')
		repo.save(@post)
	end

	def expected_post_array(expected_ids)
		list = []
		expected_ids.each do |id| 
			p = Blux::Post.new('test')
			p.id = id

			list << p
		end

		list
	end
end
