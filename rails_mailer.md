## Interceptor
Within file: ```config/initializers/smtp.rb```
```ruby
ActionMailer::Base.register_interceptor(BlackListDomainMailerInterceptor)
```

class ```BlackListDomainMailerInterceptor``` definition:

```ruby
class BlackListDomainMailerInterceptor
  class << self
    def delivering_email(mail)
      domains = parse_domains(mail.to)
      mail.perform_deliveries = (domains - blacklist_domains).any?

      unless mail.perform_deliveries
        Rails.logger.info("[Mailer][BlackListDomainMailerInterceptor]Email: [#{mail.to}] filtered")
      end
    end

    private

    def parse_domains(to)
      Array(to).map do |email|
        email.to_s.split('@').last.strip.downcase
      end
    end

    def blacklist_domains
      ENV['BLACKLIST_EMAIL_DOMAINS'].to_s.split(',').map do |domain|
        domain.strip.downcase
      end
    end
  end
end
```
