require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +Synonym+ model.
class SynonymTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = true

  test 'should create synonym' do
    assert_difference 'Synonym.count' do
      create_synonym
    end
  end

  test 'should require name' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(name: nil)
      assert s.errors[:name].any?
    end
  end

  test 'should require original' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(original: nil)
      assert s.errors[:original].any?
    end
  end

  test 'should require weight' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(weight: nil)
      assert s.errors[:weight].any?
    end
  end

  test 'should require unique name within scope' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(original: synonyms(:afval_vuilnis).original, name: synonyms(:afval_vuilnis).name)
      assert s.errors[:name].any?
    end
  end

  test 'should allow unique name without scope' do
    assert_difference 'Synonym.count' do
      create_synonym(name: synonyms(:afval_vuilnis).name)
    end
  end

  test 'should require numerical weight' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(weight: 'quux')
      assert s.errors[:weight].any?
    end
  end

  test 'should require positive weight' do
    assert_no_difference 'Synonym.count' do
      s = create_synonym(weight: -1)
      assert s.errors[:weight].any?
    end
  end

  test 'should allow fractional weight' do
    assert_difference 'Synonym.count' do
      create_synonym(weight: 0.25)
    end
  end

  test 'should require node' do
    assert_no_difference 'Synonym.count' do
      create_synonym(node: nil)
    end
  end

  protected

  def create_synonym(options = {})
    Synonym.create({
      original: 'foo',
      name: 'bar',
      weight: '0.25',
      node: nodes(:root_section_node)
    }.merge(options))
  end
end
