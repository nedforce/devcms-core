require File.dirname(__FILE__) + '/../test_helper'

class AbbreviationTest < ActiveSupport::TestCase

  def test_should_create_abbreviation
    assert_difference 'Abbreviation.count' do
      create_abbreviation
    end
  end

  def test_should_require_abbr
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(:abbr => nil)
      assert abbr.errors.on(:abbr)
    end
  end

  def test_should_require_definition
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(:definition => nil)
      assert abbr.errors.on(:definition)
    end
  end

  def test_should_require_node
    assert_no_difference 'Abbreviation.count' do
      abbr = create_abbreviation(:node => nil)
      assert abbr.errors.on(:node)
    end
  end

  def test_should_do_fuzzy_search
    %w(wmo WMO Wmo w.m.o W.M.O W.M.O.).each do |abbr|
      results = Abbreviation.search(abbr)
      assert_equal 1, results.length
      assert_equal abbreviations(:wmo), results.first
    end
  end

  protected

  def create_abbreviation(options = {})
    Abbreviation.create({ :abbr => "snafu", :definition => "Situation Normal All Fucked Up", :node => nodes(:root_section_node)}.merge(options))
  end

end
