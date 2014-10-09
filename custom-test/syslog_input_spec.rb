require "test_utils"
require 'pp'

BEGIN {
  # Even though all our servers should be in UTC lets check we are dealing with Timezones right.
  if defined? :org # a.k.a. JRUBY
    org.joda.time.DateTimeZone.setDefault( org.joda.time.DateTimeZone.forID "America/Los_Angeles" )
  end
}

module TestHelpers
  TEST_SYSLOG_PORT =  22514

  def test_syslog_message(message, &block)
    socket = Stud.try(5.times) { TCPSocket.new("127.0.0.1", TEST_SYSLOG_PORT) }
    socket.puts message
    event = @queue.pop
    begin
      instance_exec(event, &block)
    rescue
      pp event.to_hash
      raise
    end
  end

  # We want to test with the 'Real' config as much as possible. But we only
  # want input from the test, not from the host at large. So we alter the
  # config and replace the inputs section
  #
  # This was done by putting logstash into debug mode and then looking at what
  # the code it generated. If this proves too flakey in the future an
  # alternative would be to regex out the input{...} block out and replace that
  def alter_pipeline_inputs(pipeline)
    port = TEST_SYSLOG_PORT
    pipeline.instance_eval do
      @inputs = []
      @inputs << plugin("input", "tcp", LogStash::Util.hash_merge_many({ "port" => port }, { "type" => ("syslog".force_encoding("UTF-8")) }))
    end
  end

  def test_logstash(&block)
    instance_eval do
      # Cribbed from https://github.com/elasticsearch/logstash/blob/0d18814d024b4dc65382de7b6e1366381b16b561/spec/inputs/syslog.rb
      input do |pipeline, queue|
        @queue = queue
        alter_pipeline_inputs(pipeline)

        Thread.new { pipeline.run }
        sleep 0.1 while !pipeline.ready?

        instance_exec &block
      end
    end
  end

end

describe "syslog messages", :socket => true do

  extend LogStash::RSpec
  extend TestHelpers

  # TODO: Make sure the config files match what we pass to upstart?
  config [ '/etc/logstash/indexer.conf' ].map { |fn| File.open(fn).read }.reduce(:+)

  test_logstash do

    # iptables logs

    # Stub the time out. Since Syslog doesn't include year in it's dates by
    # default lets make sure we pass past 2014
    Time.stub( :now ).and_return( Time.local(2014,7,13,19,40,23) )

    line = "<5>Jul 8 06:51:09 master.prod1 kernel: [314236.389814] IPTables-Dropped: IN=eth0 OUT= MAC=00:50:56:01:0a:0b:00:50:56:8e:54:fd:08:00 SRC=10.5.12.100 DST=10.5.11.100 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=8247 DF PROTO=TCP SPT=54612 DPT=4506 WINDOW=29200 RES=0x00 SYN URGP=0"

    test_syslog_message(line) do |event|

      reject { event["tags"] || [] }.include? "_grokparsefailure"
      reject { event }.include? "sayslog_message"
      insist { event["@message"] } ==  "[314236.389814] IPTables-Dropped: IN=eth0 OUT= MAC=00:50:56:01:0a:0b:00:50:56:8e:54:fd:08:00 SRC=10.5.12.100 DST=10.5.11.100 LEN=60 TOS=0x00 PREC=0x00 TTL=63 ID=8247 DF PROTO=TCP SPT=54612 DPT=4506 WINDOW=29200 RES=0x00 SYN URGP=0"
      insist { event["host"] } == "master.prod1"
      insist { event["type"] } == "syslog"
      insist { event["syslog_facility"] } == "kernel"
      insist { event["syslog_severity"] } == "notice"
      insist { event["syslog_program"] } == "kernel"

      # Event time should be taken from the syslog entry. Cos there's no TZ in there and we haven't set one in the date filter it will correct for DST....
      insist { event.timestamp.utc.iso8601 } == "2014-07-08T13:51:09Z"

      # Check that our grok rules for iptables worked
      insist { event["dst_port"] } == "4506"
      insist { event["src_port"] } == "54612"

      # Check that the received_at was converted to a proper timestamp, not a string
      insist { event["received_at"] }.is_a? Time
      insist { event["received_at"].iso8601 } == "2014-07-14T02:40:23Z"
  end

=begin haproxy example
    line = %q{<134>Jul 9 11:08:50 localhost haproxy[4494]: 81.134.202.29:41294 [09/Jul/2014:11:08:49.463] https~ apps.pvb/apps.pvb1 966/0/0/0/966 200 1599 - - ---- 8/8/0/1/0 0/0 {|Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:30.0) Gecko/20100101 Firefox/30.0} "GET /app/panels/table/micropanel.html HTTP/1.1" {request_id=5186CA1D:A14E_AC1F2FAE:01BB_53BD22C1_1116:118E,- ssl_version=TLSv1.2 ssl_cypher=ECDHE-RSA-AES128-GCM-SHA256}}

    test_syslog_message(line) do |event|
      reject { event["tags"] || [] }.include? "_grokparsefailure"
      insist { event["syslog_facility"] } == "local0"
      insist { event["syslog_severity"] } == "informational"
      insist { event["client_ip"] } == "81.134.202.29"
      insist { event["ssl_cypher"] } == "ECDHE-RSA-AES128-GCM-SHA256"
    end
=end

    # Other syslog messages
    line = "<86>Jul 8 12:30:01 ac-front.prod1 CRON[20083]: pam_unix(cron:session): session opened for user accelerated_claims by (uid=0)"
    test_syslog_message(line) do |event|
      reject { event["tags"] || [] }.include? "_grokparsefailure"
      insist { event["host"] } == "ac-front.prod1"
      insist { event["type"] } == "syslog"
      insist { event["syslog_facility"] } == "security/authorization"
      insist { event["syslog_program"] } == "CRON"
      insist { event["@message"] } == "pam_unix(cron:session): session opened for user accelerated_claims by (uid=0)"
      insist { event.timestamp.iso8601 } == "2014-07-08T19:30:01Z"
    end

    # apparmor
    line = "<5>Aug 29 13:41:59 ip-172-31-18-91 kernel: [   15.199355] type=1400 audit(1409319719.698:10): apparmor=\"STATUS\" operation=\"profile_replace\" name=\"/usr/lib/connman/scripts/dhclient-script\" pid=777 comm=\"apparmor_parser\""
    test_syslog_message(line) do |event|
      reject { event["tags"] || [] }.include? "_grokparsefailure"
      insist { event["apparmor_evt"] } == "STATUS"
      insist { event["apparmor_rest"] } == "operation=\"profile_replace\" name=\"/usr/lib/connman/scripts/dhclient-script\" pid=777 comm=\"apparmor_parser\""
    end

    line = "<5>Aug 29 13:41:59 ip-172-31-18-91 kernel: [   15.199355] type=1400 audit(1409319719.698:10): apparmor=\"ALLOWED\" operation=\"truncate\" parent=15066 profile=\"/usr/bin/python2.7\" name=\"/tmp/lala123\" pid=15167 comm=\"python\" requested_mask=\"w\" denied_mask=\"w\" fsuid=1000 ouid=1000"
    test_syslog_message(line) do |event|
      reject { event["tags"] || [] }.include? "_grokparsefailure"
      insist { event["apparmor_evt"] } == "ALLOWED"
      insist { event["apparmor_rest"] } == "operation=\"truncate\" parent=15066 profile=\"/usr/bin/python2.7\" name=\"/tmp/lala123\" pid=15167 comm=\"python\" requested_mask=\"w\" denied_mask=\"w\" fsuid=1000 ouid=1000"
    end

    line = "<5>Aug 29 13:41:59 ip-172-31-18-91 kernel: [   15.199355] type=1400 audit(1409319719.698:10): apparmor=\"DENIED\" operation=\"mknod\" parent=15066 profile=\"/usr/bin/python2.7\" name=\"/tmp/alal1234\" pid=15300 comm=\"python\" requested_mask=\"c\" denied_mask=\"c\" fsuid=1000 ouid=1000"
    test_syslog_message(line) do |event|
      reject { event["tags"] || [] }.include? "_grokparsefailure"
      insist { event["apparmor_evt"] } == "DENIED"
      insist { event["apparmor_rest"] } == "operation=\"mknod\" parent=15066 profile=\"/usr/bin/python2.7\" name=\"/tmp/alal1234\" pid=15300 comm=\"python\" requested_mask=\"c\" denied_mask=\"c\" fsuid=1000 ouid=1000"
    end
  end
end

