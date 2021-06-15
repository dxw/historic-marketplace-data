# frozen_string_literal: true

module HistoricMarketplaceData
  class CSV
    URL = ENV["MARKETPLACE_CSV"]

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
