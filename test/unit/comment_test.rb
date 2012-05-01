require File.expand_path('../../test_helper.rb', __FILE__)

class CommentTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def setup
    @user = users(:arthur)
    @news_item_node = news_items(:devcms_news_item).node
  end

  def test_should_create_comment
    assert_difference 'Comment.count' do
      create_comment
    end
  end

  def test_should_validate_length
    username = "FooBarBazQuuxMosHenkDef"*100
    assert_no_difference 'Comment.count' do
      create_comment(:user_name => username, :user => nil)
    end
  end

  def test_should_require_user
    assert_no_difference 'Comment.count' do
      comment = create_comment(:user => nil)
      assert comment.errors[:user].any?
    end
  end

  def test_user_takes_precedence_over_user_name
    comment = create_comment(:user => @user, :user_name => @user.login.succ)
    assert_equal @user.login, comment.user_name
  end

  def test_should_require_commentable
    assert_no_difference 'Comment.count' do
      comment = create_comment(:commentable => nil)
      assert comment.errors[:commentable].any?
    end
  end

  def test_should_require_comment_body
    assert_no_difference 'Comment.count' do
      comment = create_comment(:comment => nil)
      assert comment.errors[:comment].any?
    end

    assert_no_difference 'Comment.count' do
      comment = create_comment(:comment => '')
      assert comment.errors[:comment].any?
    end
  end

  def test_should_not_require_unique_title
    assert_difference 'Comment.count', 2 do
      2.times do
        comment = create_comment(:title => 'Non-unique title')
        assert !comment.errors[:title].any?
      end
    end
  end

  def test_should_destroy_comment
    create_comment
    assert_difference "Comment.count", -1 do
      @news_item_node.destroy
    end
  end

  def test_should_have_nodes
    c = create_comment
    c.node == c.commentable
  end

  def test_should_return_editable_comments
    assert_equal Comment.all, Comment.editable_comments_for(users(:arthur))

    editable_comment = create_comment(:user => users(:final_editor))
    editable_comment2 = create_comment(:user => users(:final_editor), :commentable => nodes(:economie_section_node))
    non_editable_comment = create_comment

    editable_comments = Comment.editable_comments_for(users(:final_editor))
    assert editable_comments.include?(editable_comment)
    assert editable_comments.include?(editable_comment2)
    assert !editable_comments.include?(non_editable_comment)

    editable_comment = create_comment(:user => users(:editor))
    editable_comments = Comment.editable_comments_for(users(:editor))
    assert editable_comments.include?(editable_comment)
    assert !editable_comments.include?(non_editable_comment)
  end

protected

  def create_comment(options = {})
    Comment.create({ :user => @user, :commentable => @news_item_node, :comment => "I don't like it!" }.merge(options))
  end

end

