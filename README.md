This project contains code for a Ruby-on-Rails web site that displays data
about aerobatic contests, including contest results, pilot standings,
and judge metrics.

Find this deployed on the [web site](https://iaccdb.iac.org/)
of the International Aerobatic Club (IAC).

## Development

To make this work locally:

 - [Fork the repository](https://guides.github.com/activities/forking/)
   and clone it to your workspace
 - Have installed mysql
 - Have installed ruby, rubygems, and bundler.
   Ruby ought to be the version specified by `.ruby-version`.
   We find [rbenv](https://github.com/rbenv/rbenv) to be most useful.
   ```
   rbenv install `cat .ruby-version`
   gem install bundler
   ```
 - Copy the `config/admin.yml.sample` to `config/admin.yml`
 - Copy the `config/database.yml.sample` to `config/database.yml`
 - In the mysql client (`> mysql -u root`):
     - create the `cdb_dev` and `cdb_test` databases
       ```sql
       mysql> create database cdb_dev \
           -> character set utf8mb4 collate utf8mb4_unicode_ci;
       ```
     - create the `cdbusr` user with global permissions to the two databases
       ```sql
       mysql> create user 'cdbusr'@'localhost' identified by 'ei9vDmJN';
       mysql> grant all privileges on cdb_dev.* to 'cdbusr'@'localhost';
       mysql> grant all privileges on cdb_test.* to 'cdbusr'@'localhost';
       ```
       The password in the "`create user`" command matches that
       in `database.yml`.  The user name, "`cdbuser`" matches
       that in `database.yml`.
 - Install the gems: `bundle install`
 - Run the Rails database setup script for development and test:
      - `rails db:setup`
      - `RAILS_ENV=test rails db:setup`

Having done that,
 - The command "`rspec spec`" should run the older tests.
 - The command "`rails test`" should run the newer tests.
 - The command "`rails server`" should
   start a server at `http://localhost:3000`.

## Contributions

We follow [GitHub Flow](https://guides.github.com/introduction/flow/).
Any pull request you make will receive a response.
[Issue fixes](https://github.com/wbreeze/iaccdb/issues) are welcome,
especially when they include tests. Tests are welcome.
If your contribution
might require significant time and effort,
it's safest to get in touch first with your proposal.
