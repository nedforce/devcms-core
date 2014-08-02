require File.expand_path('../../test_helper.rb', __FILE__)

class SynonymTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  def test_should_create_synonym
    assert_difference 'Synonym.count' do
      create_synonym
    end
  end

  def test_should_require_name
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:name => nil)
      assert s.errors[:name].any?
    end
  end

  def test_should_require_original
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:original => nil)
      assert s.errors[:original].any?
    end
  end

  def test_should_require_weight
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:weight => nil)
      assert s.errors[:weight].any?
    end
  end

  def test_should_require_unique_name_within_scope
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:original => synonyms(:afval_vuilnis).original, :name => synonyms(:afval_vuilnis).name)
      assert s.errors[:name].any?
    end
  end

  def test_should_allow_unique_name_without_scope
    assert_difference 'Synonym.count' do
      create_synonym(:name => synonyms(:afval_vuilnis).name)
    end
  end

  def test_should_require_numerical_weight
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:weight => "quux")
      assert s.errors[:weight].any?
    end
  end

  def test_should_require_positive_weight
    assert_no_difference 'Synonym.count' do
      s = create_synonym(:weight => -1)
      assert s.errors[:weight].any?
    end
  end

  def test_should_allow_fractional_weight
    assert_difference 'Synonym.count' do
      create_synonym(:weight => 0.25)
    end
  end

  def test_should_require_node
    assert_no_difference 'Synonym.count' do
      create_synonym(:node => nil)
    end
  end

  protected

  def create_synonym(options = {})
    Synonym.create({ :original => 'foo', :name => 'bar', :weight => '0.25', :node => nodes(:root_section_node) }.merge(options))
  end
end
