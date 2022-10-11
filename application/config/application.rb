# frozen_string_literal: true

uncomment_lines 'config/application.rb', /config\.time_zone = .+/
gsub_file 'config/application.rb', /config.time_zone = 'Central Time (US & Canada)'/, "config.time_zone = 'Eastern Time (US & Canada)'"

if requires_sidekiq?
  insert_into_file 'config/application.rb', <<-RUBY, before: '  end'
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.deliver_later_queue_name = 'mailers'
  RUBY
end
