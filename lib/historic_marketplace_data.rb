# frozen_string_literal: true

require 'dotenv'
Dotenv.load

require 'open-uri'
require 'csv'
require 'marketplace_opportunity_scraper'
require 'google_drive'

require 'historic_marketplace_data/csv'
require 'historic_marketplace_data/opportunity'
require 'historic_marketplace_data/spreadsheet_writer'

module HistoricMarketplaceData
end
