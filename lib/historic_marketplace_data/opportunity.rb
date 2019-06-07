# frozen_string_literal: true

module HistoricMarketplaceData
  class Opportunity
    class << self
      def all
        data.map { |row| new(row) }
      end

      def spreadsheet
        Spreadsheet.new
      end

      def new_data
        ids = spreadsheet.ids
        new_rows = data.reject { |r| ids.include?(r[0]) }
        new_rows.map { |row| new(row) }
      end

      def data
        CSV.new.data.select { |r| r['Category'] == 'digital-outcomes' }
      end

      def add_all_to_spreadsheet
        add_to_spreadsheet(all.map(&:to_a))
      end

      def append_to_spreadsheet
        add_to_spreadsheet(new_data.map(&:to_a))
      end

      private

      def add_to_spreadsheet(outcomes)
        spreadsheet.append_rows(outcomes)
      end
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
