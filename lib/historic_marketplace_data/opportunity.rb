# frozen_string_literal: true

module HistoricMarketplaceData
  class Opportunity
    def self.all
      CSV.new.data.map do |row|
        new(row) if row['Category'] == 'digital-outcomes'
      end.reject(&:nil?)
    end

    def self.add_all_to_spreadsheet
      outcomes = all.map(&:to_a)
      SpreadsheetWriter.new.append_rows(outcomes)
    end

    def initialize(row)
      @row = row
    end

    def to_a
      [row.fields, description, budget].flatten
    end

    private

    attr_reader :row

    def description
      additional_data.description
    end

    def budget
      additional_data.budget
    end

    def id
      row[0]
    end

    def additional_data
      @additional_data ||= begin
        MarketplaceOpportunityScraper::Opportunity.find(id)
      end
    end

    def to_method(header)
      header.downcase.gsub(' ', '_').to_sym
    end
  end
end
