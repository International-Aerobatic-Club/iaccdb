# Local Setup

## Prerequisites

- MySQL
- Ruby (version specified in `.ruby-version` — use [rbenv](https://github.com/rbenv/rbenv))
- Bundler

## Steps

### 1. Clone and configure

```bash
git clone https://github.com/wbreeze/iaccdb.git
cd iaccdb
rbenv install $(cat .ruby-version)
gem install bundler
```

Copy the sample config files:

```bash
cp config/admin.yml.sample config/admin.yml
cp config/database.yml.sample config/database.yml
```

### 2. Create the MySQL databases

```sql
-- In the MySQL client (mysql -u root):
CREATE DATABASE cdb_dev CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE cdb_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'cdbusr'@'localhost' IDENTIFIED BY 'ei9vDmJN';
GRANT ALL PRIVILEGES ON cdb_dev.* TO 'cdbusr'@'localhost';
GRANT ALL PRIVILEGES ON cdb_test.* TO 'cdbusr'@'localhost';
```

The password and username match those in `config/database.yml`.

### 3. Install gems and set up the schema

```bash
bundle install
rails db:setup
RAILS_ENV=test rails db:setup
```

### 4. Load sample data

```bash
gunzip < sample_data/cdb20190423071929.sql.gz | mysql -u cdbusr -pei9vDmJN cdb_dev
```

Or load from Manny files (extract the tar files in `sample_data/` first):

```bash
rails runner cmd/loadContestDB.rb <extracted_files>
```

### 5. Run the server

```bash
rails server
```

App available at `http://localhost:3000`.

### 6. Run tests

```bash
rspec spec          # RSpec tests
rails test          # Minitest tests
```
