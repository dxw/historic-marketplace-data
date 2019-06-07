# frozen_string_literal: true

RSpec.describe HistoricMarketplaceData::Opportunity do
  let(:data) do
    [
      '9',
      'HSCIC Dev Ops Contract - SOW 1 - Spine',
      'https://www.digitalmarketplace.service.gov.uk/digital-outcomes-and-specialists/opportunities/9',
      'digital-outcomes-and-specialists',
      'digital-outcomes',
      nil,
      'Health & Social Care Information Centre (HSCIC) & Department of Health (DoH)',
      'hscic.gov.uk',
      'Yorkshire and the Humber',
      '2016-07-13',
      '2 weeks',
      '2 Years',
      '6.0',
      '6.0',
      '12.0',
      'closed',
      nil,
      nil,
      nil,
      nil
    ]
  end

  let(:headers) do
    [
      'ID', 'Opportunity', 'Link', 'Framework', 'Category',
      'Specialist', 'Organisation Name', 'Buyer Domain',
      'Location Of The Work', 'Published At', 'Open For',
      'Expected Contract Length', 'Applications from SMEs',
      'Applications from Large Organisations',
      'Total Organisations', 'Status', 'Winning supplier',
      'Size of supplier', 'Contract amount',
      'Contract start date'
    ]
  end

  let(:row) do
    CSV::Row.new(headers, data)
  end

  describe 'new' do
    let(:opportunity) { described_class.new(row) }

    it 'fetches data from the marketplace' do
      scraped_opportunity = double(MarketplaceOpportunityScraper::Opportunity)
      expect(MarketplaceOpportunityScraper::Opportunity)
        .to(receive(:find).with(row[0]).once { scraped_opportunity })

      expect(scraped_opportunity).to receive(:description)
      expect(scraped_opportunity).to receive(:budget)

      opportunity.to_a
    end

    it 'combines data from two sources' do
      expect(opportunity.to_a.count).to eq(data.count + 2)
    end
  end

  describe 'all' do
    let(:opportunities) { described_class.all }
    let(:csv) { double(data: [row, row, row]) }

    before do
      expect(HistoricMarketplaceData::CSV).to receive(:new) { csv }
    end

    it 'gets all opportunities' do
      expect(described_class).to receive(:new).with(row).exactly(3).times
      opportunities
    end
  end

  describe 'outcomes' do
    let(:outcomes) { described_class.outcomes }

    let(:specialist_row) do
      specialist_data = data.dup
      specialist_data[4] = 'digital-specialists'
      CSV::Row.new(headers, specialist_data)
    end

    let(:csv) { [row, specialist_row, row] }

    it 'filters opportunities' do
      expect(described_class).to receive(:all) { csv }
      expect(outcomes.count).to eq(2)
    end
  end
end
