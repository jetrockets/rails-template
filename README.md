# JetRockets Rails template

## Description

This is the application template that JetRockets recommend for Rails 7 projects. This tepmlate is based on original idea of
Matt Brictson application template [https://github.com/mattbrictson/rails-template](https://github.com/mattbrictson/rails-template).


## Requirements

This template currently works with:
* Rails 7.0.x
* Bundler 2.x
* PostgreSQL
* Esbuild

## Usage


To generate a Rails application using this template, pass the `-m` option to `rails new`, like this:

```
rails new blog \
  --database=postgresql \
  --javascript=esbuild \
  -m https://raw.githubusercontent.com/jetrockets/rails-template/main/template.rb
```
