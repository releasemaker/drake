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

Host hazel.rndsvc.net
  VerifyHostKeyDNS yes
  StrictHostKeyChecking no

EOF

# This will likely fail, but it will add the host key to known_hosts.
ssh circleci@hazel.rndsvc.net '/bin/true' || true
