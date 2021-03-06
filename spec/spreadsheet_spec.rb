# frozen_string_literal: true

RSpec.describe HistoricMarketplaceData::Spreadsheet do
  let(:session) { double(:session) }
  let(:worksheet) { double(num_rows: 0, save: nil) }
  let(:spreadsheet) { double(worksheets: [worksheet]) }

  subject { described_class.new }

  describe 'append_row' do
    let(:data) { %w[foo bar] }

    it 'creates a new instance of a Google Drive session' do
      expect(GoogleDrive::Session).to receive(:from_service_account_key) { session }
      expect(session).to receive(:spreadsheet_by_key) { spreadsheet }

      subject.append_row([])
    end

    it 'writes a row' do
      allow(GoogleDrive::Session).to receive(:from_service_account_key) { session }
      allow(session).to receive(:spreadsheet_by_key) { spreadsheet }

      expect(worksheet).to receive(:[]=).with(1, 1, data[0])
      expect(worksheet).to receive(:[]=).with(1, 2, data[1])
      expect(worksheet).to receive(:save).once

      subject.append_row(data)
    end

    context 'when there are already rows present' do
      let(:worksheet) { double(num_rows: 100, save: nil) }

      it 'writes a row' do
        allow(GoogleDrive::Session).to receive(:from_service_account_key) { session }
        allow(session).to receive(:spreadsheet_by_key) { spreadsheet }

        expect(worksheet).to receive(:[]=).with(101, 1, data[0])
        expect(worksheet).to receive(:[]=).with(101, 2, data[1])
        expect(worksheet).to receive(:save).once

        subject.append_row(data)
      end
    end
  end

  describe 'append_rows' do
    let(:data) { [%w[foo bar], %w[baz foo], %w[fizz buzz]] }

    it 'creates a new instance of a Google Drive session' do
      expect(GoogleDrive::Session).to receive(:from_service_account_key) { session }
      expect(session).to receive(:spreadsheet_by_key) { spreadsheet }

      subject.append_rows([[], []])
    end

    it 'writes the rows' do
      allow(GoogleDrive::Session).to receive(:from_service_account_key) { session }
      allow(session).to receive(:spreadsheet_by_key) { spreadsheet }

      expect(worksheet).to receive(:[]=).with(1, 1, data[0][0])
      expect(worksheet).to receive(:[]=).with(1, 2, data[0][1])
      expect(worksheet).to receive(:[]=).with(2, 1, data[1][0])
      expect(worksheet).to receive(:[]=).with(2, 2, data[1][1])
      expect(worksheet).to receive(:[]=).with(3, 1, data[2][0])
      expect(worksheet).to receive(:[]=).with(3, 2, data[2][1])
      expect(worksheet).to receive(:save).once

      subject.append_rows(data)
    end

    context 'when there are already rows present' do
      let(:worksheet) { double(num_rows: 100, save: nil) }

      it 'writes the rows' do
        allow(GoogleDrive::Session).to receive(:from_service_account_key) { session }
        allow(session).to receive(:spreadsheet_by_key) { spreadsheet }

        expect(worksheet).to receive(:[]=).with(101, 1, data[0][0])
        expect(worksheet).to receive(:[]=).with(101, 2, data[0][1])
        expect(worksheet).to receive(:[]=).with(102, 1, data[1][0])
        expect(worksheet).to receive(:[]=).with(102, 2, data[1][1])
        expect(worksheet).to receive(:[]=).with(103, 1, data[2][0])
        expect(worksheet).to receive(:[]=).with(103, 2, data[2][1])
        expect(worksheet).to receive(:save).once

        subject.append_rows(data)
      end
    end
  end

  context 'reading rows' do
    let(:rows) { [[1, 2, 3], [3, 4, 5]] }
    let(:worksheet) { double(num_rows: 0, save: nil, rows: rows) }

    before do
      allow(GoogleDrive::Session).to receive(:from_service_account_key) { session }
      allow(session).to receive(:spreadsheet_by_key) { spreadsheet }
    end

    describe 'rows' do
      it 'returns rows' do
        expect(subject.rows).to eq(rows)
      end
    end

    describe 'ids' do
      it 'returns the first column from each row' do
        expect(subject.ids).to eq([1, 3])
      end
    end
  end
end
