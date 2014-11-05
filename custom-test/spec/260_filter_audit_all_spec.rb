# encoding: utf-8

require "test_utils"

describe "260_filter_audit_all", :our_filters => true do
  extend LogStash::RSpec

  config [ "/etc/logstash/conf.d/260_filter_audit_all.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "type == audit, message is preserved, @timestamp is updated" do
    line = %q{type=PATH msg=audit(1415220984.915:2149385): item=0 name="/usr/bin/git" inode=9389 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00}
    sample "type" => 'audit', "message" => line do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["type"] } == "audit"
      insist { subject["message"] } == line
      insist { subject["audit_kvdata_type"] } == "PATH"
      insist { subject["@timestamp"].class } == Time
      insist { subject["@timestamp"].to_json } == %q{"2014-11-05T20:56:24.915Z"}
      insist { subject.timestamp.iso8601 } == "2014-11-05T20:56:24Z"
    end
  end

  describe "type == audit, audit_epoch, audit_rest is extracted" do
    line = %q{type=PATH msg=audit(1415220984.915:2149385): item=0 name="/usr/bin/git" inode=9389 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00}
    sample "type" => 'audit', "message" => line do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["type"] } == "audit"
      insist { subject["message"] } == line
      insist { subject["audit_kvdata_type"] } == "PATH"
      insist { subject["audit_epoch"] } == "1415220984.915"
      insist { subject["audit_rest"] } == %q{item=0 name="/usr/bin/git" inode=9389 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00}
      insist { subject["audit_rest"] } == %q{item=0 name="/usr/bin/git" inode=9389 dev=08:01 mode=0100755 ouid=0 ogid=0 rdev=00:00}
    end
  end

  describe "type == audit, audit_type == LOGIN is extracted" do
    line = %q{type=LOGIN msg=audit(1415226156.531:2159626): login pid=15377 uid=1029 old auid=1029 new auid=0 old ses=2754 new ses=2763}
    sample "type" => 'audit', "message" => line do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["type"] } == "audit"
      insist { subject["message"] } == line
      insist { subject["audit_kvdata_type"] } == "LOGIN"
      insist { subject["audit_kvdata_pid"] } == "15377"
      insist { subject["audit_type"] } == "LOGIN"
    end
  end

end
