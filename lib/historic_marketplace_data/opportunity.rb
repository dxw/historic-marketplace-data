# frozen_string_literal: true

module HistoricMarketplaceData
  class Opportunity
    class << self
      @@extract_budgets = false

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

      def all_to_spreadsheet_with_budgets
        @@extract_budgets = true
        add_to_spreadsheet(all.map(&:to_a))
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
      if @@extract_budgets
        [row.fields, budget, extracted_budget].flatten
      else
        [row.fields, description, budget].flatten
      end
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

    def extracted_budget
      # Don't bother if there's no budget text
      return if budget.nil?
      return if budget.downcase.include?("day rate")

      budgets = budget.scan(/(£?\d+[.|,]?\d*[,]?[\d]*[m|k]?)(?!\d*%)\b/i)
      # Don't bother if there's no recognisable number in the budget text
      return if budgets.nil?

      budgets.map! do |budget|
        # Strip out any pound signs & commas, replace 'k' with '000'
        budget = budget[0].gsub(/£/,"").gsub(/,/,"").gsub(/k/i, "000")
        budget = budget.partition('.').first if budget.end_with?('.')

        # If the number is in pounds and pence, strip the pence
        if budget.match(/\.00/i)
          budget = budget.partition('.00').first
        end

        # If the string is something like '3.5m', turn that into 35000000
        if budget.match(/m|\./i)
          budget = '%.0f' % (budget.to_f * 1000000)
        end
        budget
      end
      
      budgets.map(&:to_i).sort.last
    end
  end
end
