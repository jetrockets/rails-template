template 'app/controllers/home_controller.rb.tt'

unless api?
  remove_file 'app/views/layout/mailer.html.erb.tt'
  directory "app/views", force: true

  directory "app/helpers", force: true

  remove_file 'app/assets/stylesheets/application.css'
  remove_dir 'app/assets/config'

  directory "app/assets", force: true

  remove_file 'public/apple-touch-icon-precomposed.png'
  copy_file 'public/apple-touch-icon.png', force: true
  copy_file 'public/favicon-16x16.png'
  copy_file 'public/favicon-32x32.png'
  copy_file 'public/favicon-192x192.png'
  copy_file 'public/favicon.ico', force: true
  copy_file 'public/safari-pinned-tab.svg'
  copy_file 'public/manifest.webmanifest'

  # View Components
  directory "app/components", force: true
end
