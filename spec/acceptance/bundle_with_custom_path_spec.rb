require "spec_helper"

describe "Bundle with custom path" do
  it "supports --path option" do
    build_gemfile <<-Gemfile
      source "https://rubygems.org"

      gem 'appraisal', :path => #{PROJECT_ROOT.inspect}
    Gemfile

    build_appraisal_file <<-Appraisals
      appraise "breakfast" do
      end
    Appraisals

    run %(bundle install --path="vendor/bundle")
    output = run "appraisal install"

    expect(file "gemfiles/breakfast.gemfile").to be_exists
    expect(output).to include("Successfully installed bundler")
  end

  let(:gem_name) { 'activemodel' }
  let(:path) { 'vendor/bundle' }

  it 'installs gems in the --path directory' do
    build_gemfile <<-Gemfile
      source "https://rubygems.org"

      gem '#{gem_name}'
    Gemfile

    run 'bundle install --path vendor/another-path'

    build_gemfile <<-Gemfile
      source "https://rubygems.org"

      gem 'appraisal', :path => #{PROJECT_ROOT.inspect}
    Gemfile

    build_appraisal_file <<-Appraisals
      appraise "#{gem_name}" do
        gem '#{gem_name}'
      end
    Appraisals

    run %(bundle install --path="#{path}")
    run 'bundle exec appraisal install'

    result = Dir.glob("tmp/stage/#{path}/ruby/#{RUBY_VERSION}/gems/*")
             .map    { |path| path.split('/').last }
             .select { |gem| gem.include?(gem_name) }
    expect(result).not_to be_empty

    bundle_output = run 'bundle check'
    expect(bundle_output).to include("The Gemfile's dependencies are satisfied")

    appraisal_output = run 'bundle exec appraisal install'
    expect(appraisal_output).to include("The Gemfile's dependencies are satisfied")
  end
end
