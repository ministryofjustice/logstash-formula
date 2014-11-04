# encoding: utf-8

require "test_utils"

describe "250_filter_nginx_all", :our_filters => true do
  extend LogStash::RSpec

  before(:each) do
    expect(Time).to receive(:now).and_return( Time.local(2014,7,13,19,40,23) )
  end

  config [ "/etc/logstash/conf.d/250_filter_nginx_all.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "type == nginx, updates @timestamp based on timestamp_msec" do

    sample "timestamp_msec" => '1415141058.829', "type" => 'nginx', "@fields" => { "http_host" => 'www.example.com' } do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["type"] } == "nginx"
      insist { subject["@fields"]["http_host"] } == "www.example.com"
      insist { subject["@timestamp"].class } == Time
      insist { subject["@timestamp"].to_json } == %q{"2014-11-04T22:44:18.829Z"}
      insist { subject.timestamp.iso8601 } == "2014-11-04T22:44:18Z"
    end
  end

end
