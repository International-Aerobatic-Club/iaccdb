#/bin/bash
/bin/cat <<EOF >config/database.yml
test:
  adapter: mysql2
  database: iaccdb_test
  username: travis
  encoding: utf8
EOF
/bin/cat <<EOF >config/admin.yml
---
# users with passwords, and roles for http auth
users:
  - name: dclo
    password: fly4fun2win
    role: admin
  - name: drew
    password: can_draw
    role: contest_admin
  - name: airplane
    password: curator
    role: curator
EOF

