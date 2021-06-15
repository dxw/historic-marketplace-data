# Historic Marketplace Data

Imports historic marketplace data from the GOV.UK digital marketplace CSV, together with additional
data scraped directly from the marketplace.

## Installation

Clone the repo:

```bash
git clone git@github.com:dxw/historic-marketplace-data.git
```

Install the dependencies:

```bash
bundle install
```

Create a `.env` file with the following entries:

```text
GOOGLE_DRIVE_JSON_KEY={Google Drive connection details as a JSON string}
SPREADSHEET_ID={The ID of the spreadsheet to import to}
MARKETPLACE_CSV=https://assets.digitalmarketplace.service.gov.uk/digital-outcomes-and-specialists-4/communications/data/opportunity-data.csv
```

Note that the value of `MARKETPLACE_CSV` will change in the future as new versions of the Digital Outcomes & Specialists framework are released

## Usage

### Adding all data

```bash
rake add_opportunities:all
```

### Adding new data

```bash
rake add_opportunities:new
```

(You'll probably want to run this as a scheduled task)
