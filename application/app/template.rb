# frozen_string_literal: true

template 'app/controllers/home_controller.rb.tt'

unless api?
  remove_dir 'app/assets/config'
  remove_file 'app/assets/stylesheets/application.css'

  template 'app/views/layout/application.html.erb.tt', force: true
  template 'app/views/layout/shared/_analytics.html.erb.tt'
  template 'app/views/layout/shared/_favicons.html.erb.tt'
  template 'app/helpers/application_helper.rb.tt', force: true
  template 'app/helpers/meta_tags_helper.rb.tt'

  template 'app/views/home/index.html.erb.tt'
  template 'app/assets/controllers/index.js.tt'
  template 'app/assets/controllers/modal_controller.js.tt'
  template 'app/assets/entrypoints/application.js.tt'
  template 'app/assets/entrypoints/application.css.tt'
  template 'app/assets/init/index.js.tt'
  template 'app/assets/init/stimulus.js.tt'
  template 'app/assets/init/turbo.js.tt'
  template 'app/assets/stylesheets/components.css.tt'
  template 'app/assets/stylesheets/vendors.css.tt'
  template 'app/assets/stylesheets/base.css.tt'

  copy_file 'app/assets/images/og-thumb.jpg'

  remove_file 'public/apple-touch-icon-precomposed.png'
  copy_file 'public/apple-touch-icon.png', force: true
  copy_file 'public/favicon-16x16.png'
  copy_file 'public/favicon-32x32.png'
  copy_file 'public/favicon-192x192.png'
  copy_file 'public/favicon.ico', force: true
  copy_file 'public/safari-pinned-tab.svg'
  copy_file 'manifest.webmanifest'

  remove_file 'app/views/layout/mailer.html.erb.tt'
  template 'app/views/layout/mailer.html.mjml.tt'
end
