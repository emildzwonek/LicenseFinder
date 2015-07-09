require_relative '../../support/feature_helper'
require_relative '../../support/testing_dsl'

describe 'Diff report' do
  # As a non-technical product owner
  # I want to see the differences between two reports
  # So that I can easily review what changed between versions

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'shows differences between two csv reports' do
    project = developer.create_ruby_app
    project.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
    developer.execute_command('license_finder report --save=report-1.csv --format=csv')

    project.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))
    developer.execute_command('license_finder report --save=report-2.csv --format=csv')

    developer.execute_command('license_finder diff report-1.csv report-2.csv')

    expect(developer).to be_seeing('added,bar,2.0.0,GPLv2')
    expect(developer).to be_seeing('unchanged,foo,1.0.0,MIT')
  end

  specify 'save differences between two csv reports' do
    project = developer.create_ruby_app
    project.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
    developer.execute_command('license_finder report --save=report-1.csv --format=csv')

    project.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))
    developer.execute_command('license_finder report --save=report-2.csv --format=csv')

    developer.execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

    project_path = project.project_dir
    diff = IO.read(project_path+'diff.csv')

    expect(diff).to include('added,bar,2.0.0,GPLv2')
    expect(diff).to include('unchanged,foo,1.0.0,MIT')
  end
end