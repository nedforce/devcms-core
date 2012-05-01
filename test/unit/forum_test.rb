require File.expand_path('../../test_helper.rb', __FILE__)

class ForumTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true
  
  def setup
    @bewoners_forum = forums(:bewoners_forum)
  end
  
  def test_should_create_forum
    assert_difference 'Forum.count' do
      create_forum
    end
  end
   
  def test_should_require_title
    assert_no_difference 'Forum.count' do
      forum = create_forum(:title => nil)
      assert forum.errors[:title].any?
    end
  end

  def test_should_require_unique_title
    assert_no_difference 'Forum.count' do
      forum = create_forum(:title => @bewoners_forum.title)
      assert forum.errors[:title].any?
    end
  end
  
  def test_should_update_forum
    assert_no_difference 'Forum.count' do
      @bewoners_forum.title = 'New title'
      @bewoners_forum.description = 'New description'
      assert @bewoners_forum.save
    end
  end
  
  def test_should_destroy_forum
    assert_difference "Forum.count", -1 do
      @bewoners_forum.destroy
    end
  end
  
  def test_find_last_updated_forum_threads
    @bewoners_forum.forum_topics.each do |topic|
      3.times do
        thread = topic.forum_threads.create!(:title => 'bar', :user => users(:henk))
        thread.forum_posts.create!(:body => 'Foobar', :user => users(:henk))
      end
      
      first_thread = topic.forum_threads.first
      last_thread = topic.forum_threads.first(:order => 'created_at DESC')
      
      [ first_thread, last_thread ].each do |thread|
        thread.forum_posts.create!(:body => 'blaatje', :user => users(:henk))
      end
    end
    
    [ -1, 0, 2, 4 ].each do |limit|
      found_threads = @bewoners_forum.find_last_updated_forum_threads(limit)

      if limit <= 0
        assert found_threads.empty?
      else
        assert found_threads.size <= limit
        
        other_threads = @bewoners_forum.forum_topics.map(&:forum_threads).flatten - found_threads
        minimum_last_update_date = found_threads.map(&:last_update_date).min

        other_threads.each do |thread|
          assert thread.last_update_date <= minimum_last_update_date
        end

        unless other_threads.empty?
          other_thread = other_threads.first
          other_thread.forum_posts.create!(:body => 'blaatje', :user => users(:henk), :created_at => 1.year.from_now)
         
          assert @bewoners_forum.find_last_updated_forum_threads(limit).include?(other_thread)
        end
      end
    end
  end
    
protected
  
  def create_forum(options = {})
    Forum.create({:parent => nodes(:root_section_node), :title => "DevCMS forums, the best there are!", :description => "Enjoy!" }.merge(options))
  end
end
