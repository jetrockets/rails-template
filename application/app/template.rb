# frozen_string_literal: true

template 'app/controllers/home_controller.rb.tt'
template 'app/views/home/index.erb.tt' unless api?
