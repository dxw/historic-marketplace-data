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

    xit 'combines data from two sources' do
      # FIXME: Fails with "undefined method `text' for nil:NilClass"
      expect(opportunity.to_a.count).to eq(data.count + 2)
    end
  end

  describe 'all' do
    let(:opportunities) { described_class.all }

    let(:specialist_row) do
      specialist_data = data.dup
      specialist_data[4] = 'digital-specialists'
      CSV::Row.new(headers, specialist_data)
    end

    let(:csv) { double(data: [row, row, specialist_row, row, specialist_row]) }

    before do
      expect(HistoricMarketplaceData::CSV).to receive(:new) { csv }
    end

    it 'gets all digital outcomes' do
      expect(described_class).to receive(:new).with(row).exactly(3).times
      opportunities
    end
  end

  describe 'new_data' do
    let(:opportunities) { described_class.new_data }
    let(:spreadsheet) { double(:spreadsheet, ids: [1, 2, 3, 4]) }

    before do
      expect(described_class).to receive(:spreadsheet)
        .at_least(1).times
        .and_return(spreadsheet)
      expect(described_class).to receive(:data) { [[1], [2], [3], [4], [5]] }
    end

    it 'gets all digital outcomes' do
      expect(described_class).to receive(:new).with(row).once.with([5])
      opportunities
    end
  end

  describe 'add_all_to_spreadsheet' do
    let(:opportunities) { Array.new(3, double(:opportunity, to_a: [])) }
    let(:writer) { double(:writer) }

    before do
      expect(described_class).to receive(:all) { opportunities }
    end

    it 'sends all to spreadsheet' do
      expect(HistoricMarketplaceData::Spreadsheet).to receive(:new) { writer }
      expect(writer).to receive(:append_rows).with(Array.new(3, []))

      described_class.add_all_to_spreadsheet
    end
  end

  describe 'append_to_spreadsheet' do
    let(:opportunities) { Array.new(3, double(:opportunity, to_a: [])) }
    let(:writer) { double(:writer) }

    before do
      expect(described_class).to receive(:new_data) { opportunities }
    end

    it 'sends new data to spreadsheet' do
      expect(HistoricMarketplaceData::Spreadsheet).to receive(:new) { writer }
      expect(writer).to receive(:append_rows).with(Array.new(3, []))

      described_class.append_to_spreadsheet
    end
  end
end
