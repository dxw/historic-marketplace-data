# frozen_string_literal: true

RSpec.describe HistoricMarketplaceData::CSV do
  let(:csv) { described_class.new.data }

  it 'gets a csv' do
    expect(csv).to be_a(CSV::Table)
    expect(csv.first).to be_a(CSV::Row)
    expect(csv.first.headers).to eq([
                                      'ID',
                                      'Opportunity',
                                      'Link',
                                      'Framework',
                                      'Category',
                                      'Specialist',
                                      'Organisation Name',
                                      'Buyer Domain',
                                      'Location Of The Work',
                                      'Published At',
                                      'Open For',
                                      'Expected Contract Length',
                                      'Applications from SMEs',
                                      'Applications from Large Organisations',
                                      'Total Organisations',
                                      'Status',
                                      'Winning supplier',
                                      'Size of supplier',
                                      'Contract amount',
                                      'Contract start date'
                                    ])
  end
end
