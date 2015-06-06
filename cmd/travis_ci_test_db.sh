#/bin/bash
/bin/cat <<EOF >config/database.yml
test:
  adapter: mysql2
  database: iaccdb_test
  username: travis
  encoding: utf8
EOF
RAILS_ENV='test' bundle exec rake db:setup

