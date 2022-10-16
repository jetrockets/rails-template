# frozen_string_literal: true

template 'config/initializers/sidekiq.rb.tt' if requires_sidekiq?
template 'config/initializers/generators.rb.tt'

apply 'config/application.rb'
apply 'config/environments/development.rb'
apply 'config/environments/production.rb'
