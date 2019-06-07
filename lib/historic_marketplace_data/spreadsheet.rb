# frozen_string_literal: true

module HistoricMarketplaceData
  class Spreadsheet
    def append_rows(rows)
      pos = num_rows
      rows.each_with_index do |row, i|
        append_row(row, pos + i, false)
      end
      worksheet.save
    end

    def append_row(row, last_pos = num_rows, save = true)
      pos = last_pos + 1
      row.each_with_index do |cell, index|
        worksheet[pos, index + 1] = encode_cell(cell)
      end
      worksheet.save if save
    end

    private

    def encode_cell(cell)
      cell.to_s.dup.force_encoding('UTF-8')
    end

    def num_rows
      worksheet.num_rows
    end

    def last_row
      return nil if num_rows <= 1

      worksheet.rows[num_rows - 1]
    end

    def key
      @key ||= StringIO.new(ENV['GOOGLE_DRIVE_JSON_KEY'])
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(key)
    end

    def worksheet
      @worksheet ||= spreadsheet.worksheets[0]
    end

    def spreadsheet
      @spreadsheet ||= session.spreadsheet_by_key(ENV['SPREADSHEET_ID'])
    end
  end
end
