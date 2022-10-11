# frozen_string_literal: true

template 'config/initializers/sidekiq.rb.tt' if requires_sidekiq?

apply 'config/application.rb'
apply 'config/environments/development.rb'
