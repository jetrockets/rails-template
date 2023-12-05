[![Lint](https://github.com/jetrockets/rails-template/actions/workflows/lint.yml/badge.svg)](https://github.com/jetrockets/rails-template/actions/workflows/lint.yml)
# JetRockets Rails template

## Description

This is the application template that JetRockets recommend for Rails 7 projects. This tepmlate is based on original idea of
Matt Brictson application template [https://github.com/mattbrictson/rails-template](https://github.com/mattbrictson/rails-template).


## Requirements

This template currently works with:
* Rails 7.1.x
* Bundler 2.x
* PostgreSQL
* Vite

## Usage


To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```
rails new blog \
  -T \
  --database=postgresql \
  --javascript=vite \
  -m https://raw.githubusercontent.com/jetrockets/rails-template/main/application/template.rb
```
