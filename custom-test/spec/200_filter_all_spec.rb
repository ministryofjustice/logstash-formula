# encoding: utf-8

BEGIN {
  # Even though all our servers should be in UTC lets check we are dealing with Timezones right.
  if defined? :org # a.k.a. JRUBY
    org.joda.time.DateTimeZone.setDefault( org.joda.time.DateTimeZone.forID "America/Los_Angeles" )
  end
}

require "test_utils"

describe "200_filter_all", :our_filters => true do
  extend LogStash::RSpec

  # Stub the time out. Since Syslog doesn't include year in it's dates by
  # default lets make sure we pass past 2014
  before(:each) do
    expect(Time).to receive(:now).and_return( Time.local(2014,7,13,19,40,23) )
  end

  config [ "/etc/logstash/conf.d/200_filter_all.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "type => syslog, kernel IPTables-Dropped message" do

    line = %q{<5>Jul 8 06:51:09 master.prod1 kernel: [314236.389814] IPTables-Dropped: IN=eth0 OUT= MAC=00:50:56:01:0a:0b:00:50:56:8e:54:fd:08:00 SRC=10.5.12.100 DST=10.5.11.100 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=8247 DF PROTO=TCP SPT=54612 DPT=4506 WINDOW=29200 RES=0x00 SYN URGP=0}

    sample "message" => line, "type" => 'syslog' do

      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      reject { subject }.include? 'syslog_message'
      insist { subject["message"] } == line
      insist { subject["host"] } == "master.prod1"
      insist { subject["type"] } == "syslog"
      insist { subject["syslog_facility"] } == "kernel"
      insist { subject["syslog_severity"] } == "notice"
      insist { subject["syslog_program"] } == "kernel"

      # Event time should be taken from the syslog entry. Cos there's no TZ in there and we haven't set one in the date filter it will correct for DST....
      insist { subject.timestamp.utc.iso8601 } == "2014-07-08T13:51:09Z"

      # Check that our grok rules for iptables worked
      insist { subject["dst_port"] } == "4506"
      insist { subject["src_port"] } == "54612"

      # Check that the received_at was converted to a proper timestamp, not a string
      insist { subject["received_at"] }.is_a? Time
      insist { subject["received_at"].iso8601 } == "2014-07-14T02:40:23Z"

    end

  end

end
