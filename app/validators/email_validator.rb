class EmailValidator < ActiveModel::EachValidator
  REGEX = /\A[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\z/

  def validate_each(record, attribute, value)
    unless value =~ REGEX
      record.errors.add(attribute, (options[:message] || :email))
    end
  end
end
