# frozen_string_literal: true

uncomment_lines 'config/environments/production.rb', /config\.force_ssl = true/

public_file_server_regex = /config\.public_file_server\.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?\n/

insert_into_file 'config/environments/production.rb', after: public_file_server_regex do
  <<-RUBY

  # Ensure TTL works in production.
  config.public_file_server.headers = ENV["RAILS_SERVE_STATIC_FILES"].present? && {
    "Cache-Control" => "public, max-age=15552000"
  }
  RUBY
end
