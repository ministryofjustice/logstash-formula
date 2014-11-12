require "test_utils"

describe "200_filter_all", :our_filters => true do
  extend LogStash::RSpec

  config [ "/etc/logstash/conf.d/200_filter_all.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "adds a @logstash_uuid to a message without one" do
    sample "message" => "test message" do
      insist { subject["message"] } == "test message"
      insist { subject["@logstash_uuid"] } =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
    end
  end

  describe "preserves the @logstash_uuid of a message if it already exists" do
    sample "message" => "test message", "@logstash_uuid" => "12341234-1234-1234-1234-123456789012" do
      insist { subject["message"] } == "test message"
      insist { subject["@logstash_uuid"] } == "12341234-1234-1234-1234-123456789012"
    end
  end

end
