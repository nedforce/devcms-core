module DevcmsCore
  module TokenGeneration
    def generate_token!(token_column)
      generate_token(token_column)
      save validate: false
    end

    def generate_token(token_column)
      begin
        self[token_column] = SecureRandom.urlsafe_base64(32)
      end while self.class.exists?(token_column => self[token_column])
    end
  end
end
