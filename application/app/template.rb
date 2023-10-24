# frozen_string_literal: true

template 'app/controllers/home_controller.rb.tt'

unless api?
  remove_dir 'app/assets/config'
  remove_file 'app/assets/stylesheets/application.css'

  template 'app/views/home/index.html.erb.tt'
  template 'app/assets/controllers/application/index.js.tt'
  template 'app/assets/entrypoints/application.js.tt'
  template 'app/assets/entrypoints/application.css.tt'
  template 'app/assets/init/index.js.tt'
  template 'app/assets/init/stimulus.js.tt'
  template 'app/assets/init/turbo.js.tt'
  template 'app/assets/stylesheets/components.css.tt'
  template 'app/assets/stylesheets/vendors.css.tt'
  template 'app/assets/stylesheets/tailwindcss.css.tt'
end
