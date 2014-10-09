#!/bin/sh

sudo stop logstash-indexer

JAR_LOCATION=${JAR_LOCATION:-"/usr/src/packages/logstash-1.2.2-flatjar.jar"}

set -e

dir="$(dirname $0)"

java -jar $JAR_LOCATION rspec -fd "$dir"/*_spec.rb
