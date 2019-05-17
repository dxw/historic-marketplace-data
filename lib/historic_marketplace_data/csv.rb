# frozen_string_literal: true

module HistoricMarketplaceData
  class CSV
    URL = 'https://assets.digitalmarketplace.service.gov.uk/digital-outcomes-and-specialists-3/communications/data/opportunity-data.csv'

    def data
      ::CSV.parse(string, headers: true)
    end

    private

    def string
      url.open.read
    end

    def url
      URI.parse(URL)
    end
  end
end
