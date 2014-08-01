require File.expand_path('../../../test_helper.rb', __FILE__)

class Admin::PollQuestionsControllerTest < ActionController::TestCase
  self.use_transactional_fixtures = true

  def test_should_show_poll_question
    login_as :sjoerd

    get :show, :id => poll_questions(:hc_question_1).id
    assert_response :success
    assert assigns(:poll_question)
    assert_equal poll_questions(:hc_question_1).node, assigns(:node)
  end

  def test_should_get_new
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:healthcare_poll_node).id
    assert_response :success
    assert assigns(:poll_question)
    assert assigns(:poll)
  end

  def test_should_get_new_with_params
    login_as :sjoerd

    get :new, :parent_node_id => nodes(:healthcare_poll_node).id, :poll_question => { :question => 'foo' }
    assert_response :success
    assert assigns(:poll_question)
    assert_equal 'foo', assigns(:poll_question).question
  end

  def test_should_create_poll_question_and_options
    login_as :sjoerd

    assert_difference('PollQuestion.count', 1) do
      assert_difference('PollOption.count', 3) do
        create_poll_question
        assert_response :success
        assert assigns(:poll_question)
        assert !assigns(:poll_question).new_record?, assigns(:poll_question).errors.full_messages.join('; ')

        assert_equal 3, assigns(:poll_question).reload.poll_options.count
      end
    end
  end

  def test_should_create_poll_question_without_options
    login_as :sjoerd

    assert_difference('PollQuestion.count', 1) do
      assert_no_difference('PollOption.count') do
        create_poll_question(:new_poll_option_attributes => nil)
        assert_response :success
        assert !assigns(:poll_question).new_record?, assigns(:poll_question).errors.full_messages.join('; ')
      end
    end
  end

  def test_create_should_require_question
    login_as :sjoerd

    assert_no_difference('PollQuestion.count') do
      create_poll_question(:question => nil)
    end

    assert_response :success
    assert assigns(:poll_question).new_record?
    assert assigns(:poll_question).errors[:question].any?
  end

  def test_create_should_require_valid_option_text
    login_as :sjoerd

    assert_no_difference('PollQuestion.count', 'question was saved') do
      assert_no_difference('PollOption.count', 'options were saved') do
        create_poll_question(:new_poll_option_attributes => [
            {:text => nil }, # +PollOption+ requires +text+
            {:text => 'Antwoord A' }
        ])

        assert_response :success
        assert assigns(:poll_question).new_record?, 'Poll question was saved with invalid option!'
        assert assigns(:poll_question).errors[:poll_options].any?, 'No errors were found on poll_options!'
      end
    end
  end

  def test_should_get_edit
    login_as :sjoerd

    get :edit, :id => poll_questions(:hc_question_1).id, :poll_question => { :question => 'foo' }
    assert_response :success
    assert assigns(:poll_question)
    assert_equal 'foo', assigns(:poll_question).question
  end

  def test_should_update_poll_question
    login_as :sjoerd

    put :update, :id => poll_questions(:hc_question_1).id, :poll_question => { :question => 'updated question' }

    assert_response :success
    assert_equal 'updated question', assigns(:poll_question).question
  end

  def test_should_update_poll_options
    login_as :sjoerd

    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    existing_poll_option_attributes = {}

    poll_options.each do |poll_option|
      existing_poll_option_attributes.update(poll_option.id.to_s => { :text => 'New text' })
    end

    assert_no_difference 'pq.poll_options.reload.count' do
      put :update, :id => pq.id, :poll_question => { :existing_poll_option_attributes => existing_poll_option_attributes }
    end

    assert_response :success

    assigns(:poll_question).poll_options.each do |poll_option|
      assert_equal 'New text', poll_option.text
    end
  end

  def test_should_not_update_poll_options_if_a_poll_option_is_invalid
    login_as :sjoerd

    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    old_poll_option_texts = {}
    existing_poll_option_attributes = {}

    poll_options.each do |poll_option|
      poll_option_id = poll_option.id.to_s
      old_poll_option_texts.update(poll_option_id => poll_option.text)
      existing_poll_option_attributes.update(poll_option_id => { :text => nil })
    end

    assert_no_difference 'pq.poll_options.reload.count' do
      put :update, :id => pq.id, :poll_question => { :existing_poll_option_attributes => existing_poll_option_attributes }
    end

    assert_response :success

    poll_options.each do |poll_option|
      assert_equal old_poll_option_texts[poll_option.id.to_s], poll_option.reload.text
    end
  end

  def test_should_delete_poll_options
    login_as :sjoerd

    existing_poll_option_attributes = {}
    pq = poll_questions(:hc_question_1)
    poll_options = pq.poll_options
    poll_options.shift

    poll_options.each do |poll_option|
      existing_poll_option_attributes[poll_option.id.to_s] = { :text => poll_option.text }
    end

    assert_difference('pq.poll_options.reload.count', -1) do
      put :update, :id => pq.id, :poll_question => { :existing_poll_option_attributes => existing_poll_option_attributes }
    end

    assert_response :success
  end

  def test_should_add_poll_options
    login_as :sjoerd

    existing_poll_option_attributes = {}
    pq = poll_questions(:hc_question_1)

    pq.poll_options.each do |poll_option|
      existing_poll_option_attributes[poll_option.id.to_s] = { :text => poll_option.text }
    end

    assert_difference('pq.poll_options.reload.count', 2) do
      put :update, :id => pq.id, :poll_question => {
        :existing_poll_option_attributes => existing_poll_option_attributes,
        :new_poll_option_attributes => [ { :text => 'Option 1' }, { :text => 'Option 2'} ] 
      }
    end

    assert_response :success
  end

  def test_should_not_add_poll_options_if_a_poll_option_is_invalid
    login_as :sjoerd

    existing_poll_option_attributes = {}
    pq = poll_questions(:hc_question_1)

    pq.poll_options.each do |poll_option|
      existing_poll_option_attributes[poll_option.id.to_s] = { :text => poll_option.text }
    end

    assert_no_difference 'pq.poll_options.reload.count' do
      put :update, :id => pq.id, :poll_question => {
        :existing_poll_option_attributes => existing_poll_option_attributes,
        :new_poll_option_attributes => [ { :text => nil }, { :text => 'Option 2'} ]
      }
    end

    assert_response :success
  end

  def test_should_not_update_question_if_nil
    login_as :sjoerd

    put :update, :id => poll_questions(:hc_question_1).id, :poll_question => { :question => nil }
    assert_response :success
    assert assigns(:poll_question).errors[:question].any?
  end

  def test_should_set_publication_start_date_on_create
    login_as :sjoerd

    assert_difference('PollQuestion.count') do
      date = 1.year.from_now
      create_poll_question :publication_start_date => date
      assert_response :success
      assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:poll_question).publication_start_date
    end
  end

  def test_should_set_publication_start_date_on_update
    login_as :sjoerd

    date = 1.year.from_now

    put :update, :id => poll_questions(:hc_question_1),
                 :poll_question => { :publication_start_date_day => date.strftime("%d-%m-%Y"), :publication_start_date_time => date.strftime("%H:%M") }

    assert_response :success
    assert_equal Time.local(date.year, date.month, date.day, date.hour, date.min), assigns(:poll_question).publication_start_date
  end

protected

  def create_poll_question(attributes = {}, options = {})
    publication_start_date = attributes.delete(:publication_start_date) || Time.zone.now

    unless attributes.has_key?(:new_poll_option_attributes)
      attributes[:new_poll_option_attributes] = [
        { :text => 'Option one' },
        { :text => 'Option two' },
        { :text => 'Option three' }
      ]
    end

    post :create, {:parent_node_id => nodes(:healthcare_poll_node).id, :poll => polls(:healthcare_poll), :poll_question => { :question => 'Question?', :publication_start_date_day => publication_start_date.strftime("%d-%m-%Y"), :publication_start_date_time => publication_start_date.strftime("%H:%M") }.merge(attributes) }.merge(options)
  end
end
