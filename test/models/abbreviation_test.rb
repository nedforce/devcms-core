require File.expand_path('../../test_helper.rb', __FILE__)

# Unit tests for the +Abbreviation+ model.
class AbbreviationTest < ActiveSupport::TestCase
  test 'should create abbreviation' do
    assert_difference 'Abbreviation.count' do
      abbr = create_abbreviation
      assert !abbr.new_record?, "#{abbr.errors.full_messages.to_sentence}"
    end
  end

  test 'should require abbr' do
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(abbr: nil)
      assert abbr.errors[:abbr].any?
    end
  end

  test 'should require definition' do
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(definition: nil)
      assert abbr.errors[:definition].any?
    end
  end

  test 'should require node' do
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(node: nil)
      assert abbr.errors[:node].any?
    end
  end

  test 'should normalize abbr' do
    %w(wmo WMO Wmo w.m.o W.M.O W.M.O.).each do |abbr|
      assert_equal 'wmo', Abbreviation.normalize(abbr)
    end
  end

  test 'should do fuzzy search' do
    %w(wmo WMO Wmo w.m.o W.M.O W.M.O.).each do |abbr|
      results = Abbreviation.search(abbr)
      assert_equal 1, results.length
      assert_equal abbreviations(:wmo), results.first
    end
  end

  protected

  def create_abbreviation(options = {})
    Abbreviation.create({
      abbr: 'snafu',
      definition: 'Situation Normal All Fucked Up',
      node: nodes(:root_section_node)
    }.merge(options))
  end
end
