require File.expand_path('../../test_helper.rb', __FILE__)

class FaqTest < ActiveSupport::TestCase
  def test_should_use_structure
    assert_difference "FaqArchive.count" do
      FaqArchive.create(:parent => Node.root, :title => 'FAQ', :description => 'Vragen en antwoorden').tap do |fa|
        assert !fa.new_record?, fa.errors.full_messages.join
        Faq.create(:parent => fa.node, :question => 'Vraag', :answer => 'Antwoord').tap do |faq|
          assert !faq.valid?, faq.errors.full_messages.join
          assert faq.new_record?, faq.errors.full_messages.join
        end
        assert_difference "FaqTheme.count" do
          FaqTheme.create(:parent => fa.node, :title => "Faq Thema").tap do |ft|
            assert !ft.new_record?, ft.errors.full_messages.join
            Faq.create(:parent => ft.node, :question => 'Vraag', :answer => 'Antwoord').tap do |faq|
              assert !faq.valid?, faq.errors.full_messages.join
              assert faq.new_record?, faq.errors.full_messages.join
            end
            assert_difference "FaqCategory.count" do
              FaqCategory.create(:parent => ft.node, :title => "Faq Categorie").tap do |fc|
                assert !fc.new_record?, fc.errors.full_messages.join
                assert_difference "Faq.count" do
                  Faq.create(:parent => fc.node, :question => 'Vraag', :answer => 'Antwoord').tap do |faq|
                    assert faq.valid?, faq.errors.full_messages.join
                    assert !faq.new_record?, faq.errors.full_messages.join
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
