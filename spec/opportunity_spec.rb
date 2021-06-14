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
    context 'when extracted budgets are not required' do
      let(:opportunity) { described_class.new(row) }

      it 'fetches data from the marketplace' do
        scraped_opportunity = double(MarketplaceOpportunityScraper::Opportunity)
        expect(MarketplaceOpportunityScraper::Opportunity)
          .to(receive(:find).with(row[0]).once { scraped_opportunity })

        expect(scraped_opportunity).to receive(:description)
        expect(scraped_opportunity).to receive(:budget)

        opportunity.to_a
      end
    end

    context 'when extracted budgets are required' do
      let(:opportunity) { described_class.new(row) }

      before do
        scraped_opportunity = double(MarketplaceOpportunityScraper::Opportunity)
        expect(MarketplaceOpportunityScraper::Opportunity)
          .to(receive(:find).with(row[0]).once { scraped_opportunity })

        allow(scraped_opportunity).to receive(:budget).and_return(budget_string)

        HistoricMarketplaceData::Opportunity.class_variable_set(:@@extract_budgets, true)
      end

      context 'a simple budget string' do
        let(:budget_string) { 'We are offering £100,000' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("We are offering £100,000",100000)
        end
      end

      context '30-40k' do
        let(:budget_string) { 'We are offering £30-40k' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("We are offering £30-40k",40000)
        end
      end

      context 'Maximum cost of £150,000 exc VAT' do
        let(:budget_string) { 'Maximum cost of £150,000 exc VAT' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("Maximum cost of £150,000 exc VAT",
                                              150000)
        end
      end

      context 'Up to £2m over the term of the contract' do
        let(:budget_string) { 'Up to £2m over the term of the contract' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("Up to £2m over the term of the contract",
                                              2000000)
        end
      end

      context '£3.5m' do
        let(:budget_string) { '£3.5m' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("£3.5m",
                                              3500000)
        end
      end

      context 'Budget range for 11 months development and 9 months additional support is between £2M to £2.5M' do
        let(:budget_string) { 'Budget range for 11 months development and 9 months additional support is between £2M to £2.5M' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("Budget range for 11 months development and 9 months additional support is between £2M to £2.5M",
                                              2500000)
        end
      end

      context 'Multiple numbers in the string - choose the largest' do
        let(:budget_string) { 'The total contract value, including any extensions, shall not exceed £600,000.00 excluding VAT. The initial contract value for 9 months shall not exceed £480,000.00 excluding VAT with up to an additional £120,000.00 excluding VAT should we decide to utilise the up to 25% contingency margin' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("The total contract value, including any extensions, shall not exceed £600,000.00 excluding VAT. The initial contract value for 9 months shall not exceed £480,000.00 excluding VAT with up to an additional £120,000.00 excluding VAT should we decide to utilise the up to 25% contingency margin",
                                              600000)
        end
      end

      context 'A large number with pence' do
        let(:budget_string) { 'The total value of this requirement is up to £1400000.00 exclusive of VAT' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("The total value of this requirement is up to £1400000.00 exclusive of VAT",
                                              1400000)
        end
      end

      context 'The string contains multiple years' do
        let(:budget_string) { 'The budget for this work is capped at 1.62 million (including VAT) for 12 months from August 2018 to August 2019.' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("The budget for this work is capped at 1.62 million (including VAT) for 12 months from August 2018 to August 2019.",
                                              1620000)
        end
      end

      context 'The string contains a year and other numbers' do
        let(:budget_string) { 'Max budget is £750,000 to end of March 2019Max day rate of £1000, to include T&S' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("Max budget is £750,000 to end of March 2019Max day rate of £1000, to include T&S",
                                              750000)
        end
      end

      context 'The string contains a year followed by a period then no space before the next character' do
        let(:budget_string) { "We expect bids up to £350,000 for until 31 March 2019 with the expectation to 'front load' in this period.We expect bids in the range of £1.1 million for 1 April 2019 to 31 March 2020.We expect bids in the range of £900,000 for 1 April 2020 to end of contract / January 2021.We have budget approval until 31 March 2019." }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("We expect bids up to £350,000 for until 31 March 2019 with the expectation to 'front load' in this period.We expect bids in the range of £1.1 million for 1 April 2019 to 31 March 2020.We expect bids in the range of £900,000 for 1 April 2020 to end of contract / January 2021.We have budget approval until 31 March 2019.",
                                              1100000)
        end
      end

      context 'The string contains day rates - ignore, too hard to decipher' do
        let(:budget_string) { 'Our target average day-rate is £580.00The guideline team size for the initial Sow is as per the Existing Team entry above.' }

        it 'fetches data from the marketplace' do
          expect(opportunity.to_a).to include("Our target average day-rate is £580.00The guideline team size for the initial Sow is as per the Existing Team entry above.",
                                              nil)
        end
      end
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

  describe 'all_to_spreadsheet_with_budgets' do
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
end
