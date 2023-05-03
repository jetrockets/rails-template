# frozen_string_literal: true

if requires_coverband?
  insert_into_file 'config/routes.rb', <<-RUBY, before: 'end'
    mount Coverband::Reporters::Web.new, at: "/coverband" if Rails.env.development?
  RUBY
end

uncomment_lines 'config/routes.rb', /root "articles#index"/
gsub_file 'config/routes.rb', /root "articles#index"/, "root 'home#index'"