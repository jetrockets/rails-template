def apply_template!
  ask_for_github_pull_request_template

  copy_github_pull_request_template if requires_github_pull_request_template?
end

def ask_for_github_pull_request_template
  @requires_github_pull_request_template ||= ask_with_default('Do you want to add PR template?', :green, 'yes')
end

def requires_github_pull_request_template?
  @requires_github_pull_request_template.strip.downcase == 'yes'
end

def copy_github_pull_request_template
  copy_file 'github/pull_request_template.md', '.github/pull_request_template.md', force: true
end

apply_template!
