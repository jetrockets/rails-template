# frozen_string_literal: true

RAILS_REQUIREMENT = '~> 7.1.2'
NODEJS_REQUIREMENT = 14
NPM_REQUIREMENT = 8

def apply_template!
  assert_minimum_rails_version
  assert_minumal_node_version
  assert_minumal_npm_version
  assert_valid_options

  add_template_repository_to_source_path

  ask_for_github
  apply 'github/template.rb' if requires_github?

  ask_for_sidekiq

  ask_for_graphql

  ask_for_coverband

  template 'Gemfile.tt', force: true
  template 'README.md.tt', force: true

  apply 'app/template.rb'
  apply 'config/template.rb'
  apply 'lib/template.rb'

  git :init unless preexisting_git_repo?

  after_bundle do
    run 'bundle exec vite install'

    unless api?
      remove_dir 'app/frontend'

      template 'postcss.config.js.tt'
      template 'tailwind.config.js.tt'
      template 'config/vite.json.tt', 'config/vite.json', force: true
      template 'vite.config.ts.tt', 'vite.config.ts', force: true
    end

    run_graphql_generator if requires_graphql?

    create_binstubs

    run_rspec_generator

    template 'Procfile.dev.tt', 'Procfile.dev', force: true

    template 'eslintrc.tt', '.eslintrc'
    template 'rubocop.yml.tt', '.rubocop.yml'
    run_rubocop_autocorrections
    add_package_json_dependency('@babel/eslint-parser', development: true)
    add_package_json_dependency('@jetrockets/eslint-config-base', development: true)
    add_package_json_dependency('@tailwindcss/forms', development: true)
    add_package_json_dependency('@tailwindcss/typography', development: true)
    add_package_json_dependency('autoprefixer', development: true)
    add_package_json_dependency('cssnano', development: true)
    add_package_json_dependency('eslint', development: true)
    add_package_json_dependency('postcss', development: true)
    add_package_json_dependency('postcss-cli', development: true)
    add_package_json_dependency('postcss-flexbugs-fixes', development: true)
    add_package_json_dependency('postcss-import', development: true)
    add_package_json_dependency('postcss-nesting', development: true)
    add_package_json_dependency('postcss-preset-env', development: true)
    add_package_json_dependency('tailwindcss', development: true)
    add_package_json_dependency('vite-plugin-compression', development: true)
    add_package_json_dependency('vite-plugin-stimulus-hmr', development: true)
    add_package_json_dependency('@hotwired/stimulus')
    add_package_json_dependency('@hotwired/turbo-rails')
    add_package_json_dependency('@rails/request.js')
    add_package_json_dependency('stimulus-library')
    add_package_json_dependency('stimulus-use')
    add_package_json_dependency('tailwindcss-stimulus-components')
    add_package_json_script('dev', 'bin\/vite dev')
    add_package_json_script('build', 'bin\/vite build')
    add_package_json_script('lint', 'eslint ./app/assets --ext .js --quiet --fix --ignore-path ./.gitignore')

    git add: '.'
    git commit: %( -m 'Initial commit' )
  end
end

# This approach is copied from the https://github.com/mattbrictson/rails-template repo.
# Read more about overwriting source paths here: https://guides.rubyonrails.org/rails_application_templates.html#advanced-usage
def add_template_repository_to_source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require 'tmpdir'

    tempdir = Dir.mktmpdir('rails-template-')
    source_paths.unshift(File.join(tempdir, 'application'))
    at_exit { FileUtils.remove_entry(tempdir) }

    git clone: [
      '--quiet',
      'https://github.com/jetrockets/rails-template.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{rails-template/(.+)/application/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.join(File.dirname(__FILE__)))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. " \
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_minumal_node_version
  node_version = `node --version`.strip.match(/\Av(\d+)\..+/)[1]
  return if node_version && node_version.to_i >= NODEJS_REQUIREMENT

  prompt = "This template requires NodeJS #{NODEJS_REQUIREMENT}. " \
           "You are using #{node_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_minumal_npm_version
  npm_version = `npm --version`.strip.match(/\A(\d+)\..+/)[1]
  return if npm_version && npm_version.to_i >= NPM_REQUIREMENT

  prompt = "This template requires npm #{NPM_REQUIREMENT}. " \
           "You are using #{npm_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_valid_options
  valid_options = {
    database: 'postgresql',
    javascript: 'vite',
    skip_gemfile: false,
    skip_bundle: false,
    skip_git: false,
    skip_test: true,
    edge: false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split('?') << " [y/n (#{default})]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def ask_for_github
  @requires_github ||= ask_with_default('Do you want to setup GitHub', :green, 'yes')
end

def requires_github?
  @requires_github.strip.downcase == 'yes'
end

def ask_for_sidekiq
  @requires_sidekiq ||=
    ask_with_default('Is Sidekiq needed in this app', :green, 'yes')
end

def requires_sidekiq?
  @requires_sidekiq.strip.downcase == 'yes'
end

def ask_for_graphql
  @requires_graphql ||=
    ask_with_default('Is Graphql needed in this app', :green, 'yes')
end

def requires_graphql?
  @requires_graphql.strip.downcase == 'yes'
end

def ask_for_coverband
  @requires_coverband ||=
    ask_with_default('Is Coverband needed in this app', :green, 'yes')
end

def requires_coverband?
  @requires_coverband.strip.downcase == 'yes'
end

def api?
  options[:api].present?
end

def preexisting_git_repo?
  @preexisting_git_repo ||= (File.exist?('.git') || :nope)
  @preexisting_git_repo == true
end

def add_package_json_dependency(name, development: false)
  command = [ 'npm', 'install', name.to_s.shellescape ]
  command << '--save-dev' if development
  run command.join(' ')
end

def add_package_json_script(name, script)
  run [ 'npm', 'pkg', 'set', "scripts.#{name.to_s.shellescape}=#{script.shellescape}" ].join(' ')
end

def run_with_clean_bundler_env(cmd)
  success =
    if defined?(Bundler)
      if Bundler.respond_to?(:with_unbundled_env)
        Bundler.with_unbundled_env { run(cmd) }
      else
        Bundler.with_clean_env { run(cmd) }
      end
    else
      run(cmd)
    end
  unless success
    puts "Command failed, exiting: #{cmd}"
    exit(1)
  end
end

def create_binstubs
  binstubs = %w[brakeman bundler-audit rubocop]
  binstubs << 'sidekiq' if requires_sidekiq?
  run_with_clean_bundler_env "bundle binstubs #{binstubs.join(" ")} --force"
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env 'bin/rubocop -A --fail-level E > /dev/null'
end

def run_rspec_generator
  run_with_clean_bundler_env 'bin/rails generate rspec:install'
end

def run_graphql_generator
  run_with_clean_bundler_env 'bin/rails generate graphql:install'
end

apply_template!
