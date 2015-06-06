#/bin/bash
mysql -e 'create database iaccdb_test;'
/bin/cat <<EOF >config/database.yml
test:
  adapter: mysql2
  database: iaccdb_test
  username: travis
  encoding: utf8
EOF

