#!/bin/sh

# To enable debugging of the logstash internals during the tests:
# export TEST_DEBUG=true

sudo stop logstash

set -e

dir="$(dirname $0)"

cd $dir

/opt/logstash/bin/logstash rspec -fd --tag socket *_spec.rb
