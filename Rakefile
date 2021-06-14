# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'historic_marketplace_data'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: %i[rubocop spec]

namespace :add_opportunities do
  task :all do
    HistoricMarketplaceData::Opportunity.add_all_to_spreadsheet
  end

  task :new do
    HistoricMarketplaceData::Opportunity.append_to_spreadsheet
  end

  task :extract_budgets do
    HistoricMarketplaceData::Opportunity.all_to_spreadsheet_with_budgets
  end
end
