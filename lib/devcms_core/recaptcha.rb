module DevcmsCore
  module Recaptcha
    RECAPTCHA_API_SERVER        = 'http://api.recaptcha.net';
    RECAPTCHA_API_SECURE_SERVER = 'https://api-secure.recaptcha.net';
    RECAPTCHA_VERIFY_SERVER     = 'api-verify.recaptcha.net';

    SKIP_VERIFY_ENV = ['test', 'cucumber']

    class RecaptchaError < StandardError
    end

    module Verify
      # Your private API can be specified in the +options+ hash or preferably
      # the environment variable +RECAPTCHA_PUBLIC_KEY+.
      def verify_recaptcha(options = {})
        if !options.is_a? Hash
          options = { :model => options }
        end

        env         = options[:env] || ENV['RAILS_ENV']
        return true if SKIP_VERIFY_ENV.include? env
        model       = options[:model]
        attribute   = options[:attribute]   || :base
        private_key = options[:private_key] || Settler[:recaptcha_private_key]
        raise RecaptchaError, I18n.t('recaptcha.no_private_key_specified') unless private_key

        begin
          recaptcha = nil
          Timeout::timeout(options[:timeout] || 3) do
            recaptcha = Net::HTTP.post_form URI.parse("http://#{RECAPTCHA_VERIFY_SERVER}/verify"), {
              "privatekey" => private_key,
              "remoteip"   => request.remote_ip,
              "challenge"  => params[:recaptcha_challenge_field],
              "response"   => params[:recaptcha_response_field]
            }
          end
          answer, error = recaptcha.body.split.map { |s| s.chomp }
          unless answer == 'true'
            if model
              model.valid?
              model.errors.add attribute, options[:message] || I18n.t('recaptcha.incorrect_word_verification_response')
            end
            return false
          else
            return true
          end
        rescue Timeout::Error
          if model
            model.valid?
            model.errors.add attribute, options[:message] || I18n.t('recaptcha.could_not_validate_word_verification_response')
          end
          return false
        rescue Exception => e
          raise RecaptchaError, e.message, e.backtrace
        end
      end # verify_recaptcha
    end # Verify

    module ClientHelper
      # Your public API can be specified in the +options+ hash or preferably
      # the environment variable +RECAPTCHA_PUBLIC_KEY+.
      def recaptcha_tags(options = {})
        # Default options
        key   = options[:public_key] ||= Settler[:recaptcha_public_key]
        raise RecaptchaError, I18n.t('recaptcha.no_public_key_specified') unless key
        error = options[:error]      ||= (defined? flash ? flash[:recaptcha_error] : "")
        uri   = options[:ssl] || request.ssl? ? RECAPTCHA_API_SECURE_SERVER : RECAPTCHA_API_SERVER
        lang  = options[:lang]       ||= I18n.locale
        html  = ""
        if options[:display]
          html << %{<script type="text/javascript">\n}
          html << %{  var RecaptchaOptions = #{options[:display].to_json.html_safe};\n}
          html << %{</script>\n}
        end
        if options[:lang]
          html << %{<script type="text/javascript">\n}
          html << %{  var RecaptchaOptions = { lang : '#{lang}'};\n}
          html << %{</script>\n}
        end
        if options[:ajax]
          html << %{<div id="dynamic_recaptcha"></div>}
          html << %{<script type="text/javascript" src="#{uri}/js/recaptcha_ajax.js"></script>\n}
          html << %{<script type="text/javascript">\n}
          html << %{  Recaptcha.create('#{key}', document.getElementById('dynamic_recaptcha')#{options[:display] ? ',RecaptchaOptions' : ''});}
          html << %{</script>\n}
        else
          html << %{<script type="text/javascript" src="#{uri}/challenge?k=#{key}}
          html << %{#{error ? "&amp;error=#{CGI::escape(error)}" : ""}"></script>\n}
          unless options[:noscript] == false
            html << %{<noscript>\n <div> }
            html << %{<object type="text/html" data="http://api.recaptcha.net/noscript?k=#{key}" }
            html << %{height="#{options[:iframe_height] ||= 300}" }
            html << %{width="#{ options[:iframe_width]  ||= 500}">\n }
            html << %{<!--[if IE]>\n }
            html << %{<iframe src="#{uri}/noscript?k=#{key}" }
            html << %{height="#{options[:iframe_height] ||= 300}" }
            html << %{width="#{ options[:iframe_width]  ||= 500}" }
            html << %{frameborder="0"></iframe>\n  }
            html << %{< ![endif]-->\n }
            html << %{</object>\n }
            html << %{<textarea name="recaptcha_challenge_field" }
            html << %{rows="#{options[:textarea_rows] ||= 3 }" }
            html << %{cols="#{options[:textarea_cols] ||= 40}"></textarea>\n  }
            html << %{<input type="hidden" name="recaptcha_response_field" value="manual_challenge"/>}
            html << %{</div>\n</noscript>\n}
          end
        end
        return raw html
      end # recaptcha_tags
    end # ClientHelper
  end # Recaptcha
end