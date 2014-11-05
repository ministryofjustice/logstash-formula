#!/bin/sh

# To enable debugging of the logstash internals during the tests:
# export TEST_DEBUG=true

sudo stop logstash

set -e

dir="$(dirname $0)"

cd $dir

if [ -z $@ ]; then
  /opt/logstash/bin/logstash rspec -fd --tag our_filters --tag socket spec/*_spec.rb
else
  /opt/logstash/bin/logstash rspec -fd --tag our_filters --tag socket $@
fi
