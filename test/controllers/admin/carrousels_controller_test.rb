require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::CarrouselsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  setup do
    @carrousel = create_carrousel
  end

  def test_should_create_carrousel
    login_as :sjoerd
    refute @carrousel.new_record?
    assert_equal [0, 'seconds'], @carrousel.human_display_time
    assert_equal 0, @carrousel.display_time
  end

  def test_should_show_approved_carrousel
    login_as :sjoerd

    get :show, :id => @carrousel.id

    assert_response :success
    assert assigns(:carrousel)
    assert_equal @carrousel.node, assigns(:node)
  end

  test 'should get new' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id
    assert_response :success
    assert assigns(:carrousel)
  end

  test 'should get new with params' do
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:root_section_node).id, :carrousel => { :title => 'foo' }
    assert_response :success
    assert assigns(:carrousel)
    assert_equal 'foo', assigns(:carrousel).title
  end

  def test_should_get_valid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Carrousel.count') do
      create_carrousel({ :title => 'foobar' }, { :commit_type => 'preview' })
      assert_response :success
      assert assigns(:carrousel).new_record?
      assert_equal 'foobar', assigns(:carrousel).title
      assert_template 'create_preview'
    end
  end

  def test_should_not_get_invalid_preview_for_create
    login_as :sjoerd

    assert_no_difference('Carrousel.count') do
      create_carrousel({ :title => nil }, { :commit_type => 'preview' })
      assert assigns(:carrousel).new_record?
      assert assigns(:carrousel).errors[:title].any?
      assert_template 'new'
    end
  end

  def test_should_require_title
    login_as :sjoerd

    assert_no_difference('Carrousel.count') do
      create_carrousel(:title => nil)
    end

    assert_template 'new'
    assert assigns(:carrousel).new_record?
    assert assigns(:carrousel).errors[:title].any?
  end

  test 'should get edit' do
    login_as :sjoerd

    get :edit, :id => @carrousel.id
    assert_response :success
    assert assigns(:carrousel)
  end

  test 'should get edit with params' do
    login_as :sjoerd

    get :edit, :id => @carrousel.id, :carrousel => { :title => 'foo' }
    assert_response :success
    assert assigns(:carrousel)
    assert_equal 'foo', assigns(:carrousel).title
  end

  def test_should_update_carrousel
    login_as :sjoerd

    put :update, :id => @carrousel.id, :carrousel => { :title => 'updated title' }

    assert_response :success
    assert_equal 'updated title', assigns(:carrousel).title
  end

  def test_should_get_valid_preview_for_update
    login_as :sjoerd

    old_title = @carrousel.title
    put :update, :id => @carrousel.id, :carrousel => { :title => 'updated title' }, :commit_type => 'preview'

    assert_response :success
    assert_equal 'updated title', assigns(:carrousel).title
    assert_equal old_title, @carrousel.reload.title
    assert_template 'update_preview'
  end

  def test_should_not_get_invalid_preview_for_update
    login_as :sjoerd

    old_title = @carrousel.title
    put :update, :id => @carrousel.id, :carrousel => { :title => nil }, :commit_type => 'preview'

    assert assigns(:carrousel).errors[:title].any?
    assert_equal old_title, @carrousel.reload.title
    assert_template 'edit'
  end

  def test_should_not_update_carrousel
    login_as :sjoerd

    put :update, :id => @carrousel.id, :carrousel => { :title => nil }
    assert_response :unprocessable_entity
    assert assigns(:carrousel).errors[:title].any?
  end

  def test_should_create_carrousel_with_items_and_display_time
    login_as :sjoerd

    post :create, :parent_node_id => nodes(:root_section_node),
                 :carrousel => { :title => 'updated title', :display_time => [5, 'hours'] },
                 :items => [ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id ],
                 :carrousel_items => { nodes(:help_page_node).id.to_s => 'Help page' }

    assert_response :success
    assert_equal 3, assigns(:carrousel).items.size
    assert_equal [5, 'hours'], assigns(:carrousel).human_display_time
    assert_equal 18_000, assigns(:carrousel).display_time
    assert_equal 'Help page', assigns(:carrousel).carrousel_items.first.excerpt
  end

  def test_should_create_carrousel_with_display_time
    login_as :sjoerd

    post :create, :parent_node_id => nodes(:root_section_node), :carrousel => { :title => 'updated title', :display_time => 300 }

    assert_response :success
    assert_equal 300, assigns(:carrousel).display_time
    assert_equal [5, 'minutes'], assigns(:carrousel).human_display_time
  end

  def test_should_add_items_and_display_time_to_carrousel
    login_as :sjoerd

    put :update, :id => @carrousel.id,
                 :carrousel => { :title => 'updated title', :display_time => [2, 'days'] },
                 :items => [ nodes(:help_page_node).id, nodes(:devcms_news_item_node).id, nodes(:devcms_news_item_voor_vorige_maand_node).id ]

    assert_response :success
    assert_equal 'updated title', assigns(:carrousel).title
    assert_equal 3, assigns(:carrousel).items.size
    assert_equal [2, 'days'], assigns(:carrousel).human_display_time
    assert_equal 60*60*24*2, assigns(:carrousel).display_time
    assigns(:carrousel).carrousel_items.each { |ci| assert_nil ci.excerpt }
  end

protected

  def create_carrousel(attributes = {}, options = {})
    login_as :sjoerd

    post :create, {
      :parent_node_id  => nodes(:root_section_node).id,
      :commit_type     => 'save',
      :carrousel       => { :title => 'new title' }.merge(attributes),
      :items           => [ nodes(:help_page_node).id ],
      :carrousel_items => { nodes(:help_page_node).id => 'Help page' }
    }.merge(options)

    assigns(:carrousel)
  end
end
