#!/bin/bash

cat >> ~/.ssh/config << EOF

Host *.do.rndsvc.net
  ProxyCommand ssh -W %h:%p nyc3.do.jump.rndsvc.net
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host *.jump.rndsvc.net
  User circleci
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  VerifyHostKeyDNS yes

EOF
