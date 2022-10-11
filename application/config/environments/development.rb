# frozen_string_literal: true

mailer_regex = /config\.action_mailer\.perform_caching = false\n/

insert_into_file 'config/environments/development.rb', after: mailer_regex do
  <<-RUBY

  # Ensure mailer works in development.
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.asset_host = "http://localhost:3000"
  RUBY
end
