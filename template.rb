# frozen_string_literal: true

RAILS_REQUIREMENT = "~> 7.0.0".freeze

def apply_template!
  assert_minimum_rails_version
  assert_valid_options

  force_default_options!

  add_template_repository_to_source_path

  ask_for_sidekiq

  template 'Gemfile.tt', force: true

  after_bundle do
    append_to_file ".gitignore", <<~IGNORE
      # Ignore application config.
      /.env.development
      /.env.*local
    IGNORE

    run './bin/rails javascript:install:esbuild'

    run_rspec_generator

    template 'rubocop.yml.tt', '.rubocop.yml'
    run_rubocop_autocorrections

    git :init
    git add: "."
    git commit: %Q{ -m 'Initial commit' }
  end
end

# This approach is copied from the https://github.com/mattbrictson/rails-template repo.
# Read more about overwriting source paths here: https://guides.rubyonrails.org/rails_application_templates.html#advanced-usage
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'

    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }

    git clone: [
      "--quiet",
      "https://github.com/jetrockets/rails-template.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

def assert_valid_options
  valid_options = {
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

def force_default_options!
  self.options = options.merge(
    database: 'postgresql',
    javascript: 'esbuild'
  )
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def ask_for_sidekiq
  @requires_sidekiq ||=
    ask_with_default("Is Sidekiq needed in this app", :blue, 'yes')
end

def requires_sidekiq?
  @requires_sidekiq.strip.downcase == 'yes'
end

def api?
  options[:api].present?
end

def run_with_clean_bundler_env(cmd)
  success = if defined?(Bundler)
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

def run_rubocop_autocorrections
  run_with_clean_bundler_env 'bundle exec rubocop -A --fail-level E > /dev/null'
end

def run_rspec_generator
  run_with_clean_bundler_env 'bin/rails generate rspec:install'
end

apply_template!