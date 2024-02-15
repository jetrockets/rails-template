template 'config/initializers/sidekiq.rb.tt' if requires_sidekiq?
template 'config/initializers/extentions.rb.tt'
template 'config/initializers/generators.rb.tt'
template 'config/initializers/mjml.rb.tt'

apply 'config/application.rb'
apply 'config/routes.rb'
apply 'config/environments/development.rb'

unless api?
  route "get '/terms', to: 'home#terms'"
  route "get '/privacy', to: 'home#privacy'"
end
