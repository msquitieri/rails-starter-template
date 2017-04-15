gem_group :development, :test do
  gem 'awesome_print'
  gem 'faker'
end

gem_group :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end

gem_group :development do
  gem 'annotate'
  gem 'guard'
  gem 'guard-annotate'
  gem 'guard-rubocop'
  gem 'guard-scss-lint'

  gem 'brakeman', require: false
  gem 'bundler-audit', '>= 0.5.0', require: false
  gem 'pry-rails'
  gem 'rubocop'
end

gem_group :production, :staging do
  gem 'unicorn'
end

run "bundle install"
generate "rspec:install"

include_factory_girl_methods = "  config.include FactoryGirl::Syntax::Methods\n"
insert_into_file "spec/rails_helper.rb", include_factory_girl_methods, after: "RSpec.configure do |config|\n"

shoulda_matchers_config = <<-EOL

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

EOL

append_to_file "spec/rails_helper.rb", shoulda_matchers_config

guardfile = <<-EOL

guard 'annotate' do
  watch('db/schema.rb')
end

guard :scsslint, all_on_start: false do
  watch(/.+\.scss$/)
end

guard :rubocop do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

EOL

create_file 'Guardfile', guardfile

rubocop_config = <<-EOL
AllCops:
  DisplayCopNames: true
  DisplayStyleGuide: true
  TargetRubyVersion: 2.4
  Exclude:
  - 'spec/spec_helper.rb'
  - 'spec/rails_helper.rb'
  - 'db/seeds.rb'
  - 'db/schema.rb'
  - 'db/migrate/*.rb'
  - 'config/initializers/*.rb'
  - 'config/puma.rb'
  - 'config/environments/*.rb'
  - 'bin/*'
  - 'Guardfile'
Documentation:
  Enabled: false
EmptyMethod:
  Enabled: false
Rails:
  Enabled: true
Style/FrozenStringLiteralComment:
  Enabled: false
Style/ClassAndModuleChildren:
  Enabled: false
Style/BlockDelimiters:
  Enabled: false
Rails/HasAndBelongsToMany:
  Enabled: false
Metrics/BlockLength:
  Exclude:
    - "spec/**/*"
Metrics/LineLength:
  Exclude:
    - "config/**/*"
    - "db/**/*"
    - Rakefile
    - Gemfile 
EOL

create_file '.rubocop.yml', rubocop_config

run 'rm -rf test/'

# Run Rubocop Autofix
run 'rubocop -a'

