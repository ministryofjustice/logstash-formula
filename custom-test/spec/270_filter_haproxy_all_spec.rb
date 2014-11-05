# encoding: utf-8

BEGIN {
  # Even though all our servers should be in UTC lets check we are dealing with Timezones right.
  if defined? :org # a.k.a. JRUBY
    org.joda.time.DateTimeZone.setDefault( org.joda.time.DateTimeZone.forID "America/Los_Angeles" )
  end
}

require "test_utils"

describe "270_filter_haproxy_all", :our_filters => true do
  extend LogStash::RSpec

  # Stub the time out. Since Syslog doesn't include year in it's dates by
  # default lets make sure we pass past 2014
  before(:each) do
    expect(Time).to receive(:now).and_return( Time.local(2014,7,13,19,40,23) )
  end

  config [ "/etc/logstash/conf.d/270_filter_haproxy_all.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "type => syslog, syslog_program == haproxy" do

    line = %q{10.10.55.55:12345 [14/Oct/2014:23:01:55.445] https~ apps.pvb/apps.pvb1 96/0/1/2/164 200 37473 - - ---- 18/18/0/0/0 0/0 {|Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25} "GET /a/page?q=wibble HTTP/1.1" {request_id=D5CDE825271A_0A010C0C01BB_5459F1AE_A692017002 ssl_version=TLSv1.2 ssl_cypher=ECDHE-RSA-AES128-SHA256}}

    sample "syslog_message" => line, "type" => 'syslog', 'syslog_program' => 'haproxy' do

      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["syslog_message"] } == line
      insist { subject["client_ip"] } == "10.10.55.55"
      insist { subject["client_port"] } == "12345"
      insist { subject["accept_date"] } == "14/Oct/2014:23:01:55.445"
      insist { subject["frontend_name"] } == "https~"
      insist { subject["backend_name"] } == "apps.pvb"
      insist { subject["server_name"] } == "apps.pvb1"
      insist { subject["time_request"] } == "96"
      insist { subject["time_queue"] } == "0"
      insist { subject["time_backend_connect"] } == "1"
      insist { subject["time_backend_response"] } == "2"
      insist { subject["time_duration"] } == "164"
      insist { subject["http_status_code"] } == "200"
      insist { subject["bytes_read"] } == "37473"
      insist { subject["captured_request_cookie"] } == "-"
      insist { subject["captured_response_cookie"] } == "-"
      insist { subject["termination_state"] } == "----"
      insist { subject["actconn"] } == "18"
      insist { subject["feconn"] } == "18"
      insist { subject["beconn"] } == "0"
      insist { subject["srvconn"] } == "0"
      insist { subject["retries"] } == "0"
      insist { subject["srv_queue"] } == "0"
      insist { subject["backend_queue"] } == "0"
      insist { subject["captured_request_headers"] } == "|Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25"
      insist { subject["captured_response_headers"] } == nil
      insist { subject["http_verb"] } == "GET"
      insist { subject["http_proto"] } == nil
      insist { subject["http_user"] } == nil
      insist { subject["http_host"] } == nil
      insist { subject["http_request"] } == "/a/page?q=wibble"
      insist { subject["http_version"] } == "1.1"
      insist { subject["keyvalue"] } == "request_id=D5CDE825271A_0A010C0C01BB_5459F1AE_A692017002 ssl_version=TLSv1.2 ssl_cypher=ECDHE-RSA-AES128-SHA256"
      insist { subject["haproxy_kvdata_request_id"] } == "D5CDE825271A_0A010C0C01BB_5459F1AE_A692017002"
      insist { subject["haproxy_kvdata_ssl_version"] } == "TLSv1.2"
      insist { subject["haproxy_kvdata_ssl_cypher"] } == "ECDHE-RSA-AES128-SHA256"

      insist { subject.timestamp.utc.iso8601 } == "2014-10-15T06:01:55Z"

    end
  end

end
