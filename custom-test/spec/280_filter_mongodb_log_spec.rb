# encoding: utf-8

BEGIN {
  # Even though all our servers should be in UTC lets check we are dealing with Timezones right.
  if defined? :org # a.k.a. JRUBY
    org.joda.time.DateTimeZone.setDefault( org.joda.time.DateTimeZone.forID "America/Los_Angeles" )
  end
}

require "test_utils"

describe "280_filter_mongodb_log", :our_filters => true do
  extend LogStash::RSpec

  # Stub the time out. Since Syslog doesn't include year in it's dates by
  # default lets make sure we pass past 2014
  before(:each) do
    expect(Time).to receive(:now).and_return( Time.local(2014,7,13,19,40,23) )
  end

  config [ "/etc/logstash/conf.d/280_filter_mongodb_log.conf" ].map { |fn| File.open(fn).read }.reduce(:+)

  describe "type => mongodb_log, make sure we get @timestamp right" do
    line = %q{2014-11-10T12:46:21.719+0000 [initandlisten] MongoDB starting : pid=25753 port=27017 dbpath=/data/mongodb 64-bit host=mongo-05.lpa-enh}
    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      insist { subject.timestamp.utc.iso8601 } == "2014-11-10T12:46:21Z"
    end
  end

  describe "type => mongodb_log, startup message" do

    line = %q{2014-11-10T12:46:21.719+0000 [initandlisten] MongoDB starting : pid=25753 port=27017 dbpath=/data/mongodb 64-bit host=mongo-05.lpa-enh}

    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["message"] } == line
      insist { subject["mongodb_log_message"] } == '[initandlisten] MongoDB starting : pid=25753 port=27017 dbpath=/data/mongodb 64-bit host=mongo-05.lpa-enh'
      insist { subject["mongodb_log_type_message"] } == 'MongoDB starting : pid=25753 port=27017 dbpath=/data/mongodb 64-bit host=mongo-05.lpa-enh'
      insist { subject.timestamp.utc.iso8601 } == "2014-11-10T12:46:21Z"
      insist { subject["mongodb_log_subtype"] } == "initandlisten"
    end

  end

  describe "type => mongodb_log, conn message" do

    line = %q{2014-12-11T07:49:51.897+0000 [conn76798]  authenticate db: local { authenticate: 1, nonce: "xxx", user: "__system", key: "xxx" }}

    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["message"] } == line
      insist { subject["mongodb_log_message"] } == '[conn76798]  authenticate db: local { authenticate: 1, nonce: "xxx", user: "__system", key: "xxx" }'
      insist { subject["mongodb_log_type_message"] } == 'authenticate db: local { authenticate: 1, nonce: "xxx", user: "__system", key: "xxx" }'
      insist { subject.timestamp.utc.iso8601 } == "2014-12-11T07:49:51Z"
      insist { subject["mongodb_log_subtype"] } == "conn"
      insist { subject["mongodb_log_conn_number"] } == 76798
    end

  end


  describe "type => mongodb_log, conn slow query message" do

    line = %q{2015-11-13T02:02:00.028+0000 [conn4671] getmore opglpa-api.application cursorid:116561480221 ntoreturn:0 exhaust:1 keyUpdates:0 numYields:8 locks(micros) r:174806 nreturned:1418 reslen:4194430 141ms}

    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["message"] } == line
      insist { subject["mongodb_log_type_message"] } == 'getmore opglpa-api.application cursorid:116561480221 ntoreturn:0 exhaust:1 keyUpdates:0 numYields:8 locks(micros) r:174806 nreturned:1418 reslen:4194430 141ms'
      insist { subject.timestamp.utc.iso8601 } == "2015-11-13T02:02:00Z"
      insist { subject["mongodb_log_subtype"] } == "conn"
      insist { subject["mongodb_log_conn_number"] } == 4671
      insist { subject["tags"] || [] }.include? "mongodb_slow_query"
      insist { subject["mongodb_log_query_operation"] } == 'getmore'
      insist { subject["mongodb_log_query_database"] } == 'opglpa-api'
      insist { subject["mongodb_log_query_collection"] } == 'application'
      insist { subject["mongodb_log_query_duration_ms"] } == 141
      insist { subject["mongodb_log_query_message"] } == 'cursorid:116561480221 ntoreturn:0 exhaust:1 keyUpdates:0 numYields:8 locks(micros) r:174806 nreturned:1418 reslen:4194430'
    end

  end

  describe "type => mongodb_log, conn slow query message -- 2" do

    line = %q{2015-01-05T14:28:39.595+0000 [conn108385] command opglpa-auth.$cmd command: update { update: "token", updates: [ { q: { _id: "e27c2727fdd1ebbc100c1cc0c1abb9b1", scopes: "" }, u: { $set: { expires: 1420472619 } }, multi: false, upsert: false } ], writeConcern: { fsync: false, j: false, wtimeout: 10, w: 1 } } keyUpdates:0 numYields:0  reslen:95 123ms}

    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["message"] } == line
      insist { subject["mongodb_log_type_message"] } == 'command opglpa-auth.$cmd command: update { update: "token", updates: [ { q: { _id: "e27c2727fdd1ebbc100c1cc0c1abb9b1", scopes: "" }, u: { $set: { expires: 1420472619 } }, multi: false, upsert: false } ], writeConcern: { fsync: false, j: false, wtimeout: 10, w: 1 } } keyUpdates:0 numYields:0  reslen:95 123ms'
      insist { subject.timestamp.utc.iso8601 } == "2015-01-05T14:28:39Z"
      insist { subject["mongodb_log_subtype"] } == "conn"
      insist { subject["mongodb_log_conn_number"] } == 108385
      insist { subject["tags"] || [] }.include? "mongodb_slow_query"
      insist { subject["mongodb_log_query_operation"] } == 'command'
      insist { subject["mongodb_log_query_database"] } == 'opglpa-auth'
      insist { subject["mongodb_log_query_collection"] } == '$cmd'
      insist { subject["mongodb_log_query_duration_ms"] } == 123
      insist { subject["mongodb_log_query_message"] } == 'command: update { update: "token", updates: [ { q: { _id: "e27c2727fdd1ebbc100c1cc0c1abb9b1", scopes: "" }, u: { $set: { expires: 1420472619 } }, multi: false, upsert: false } ], writeConcern: { fsync: false, j: false, wtimeout: 10, w: 1 } } keyUpdates:0 numYields:0  reslen:95'
    end

  end

  describe "type => mongodb_log, conn slow query message -- 3" do

    line = %q{2015-01-05T15:11:21.824+0000 [conn108425] command opglpa-api.$cmd command: count { count: "lpaInfo", query: { damage_award: true } } planSummary: COLLSCAN keyUpdates:0 numYields:1 locks(micros) r:183877 reslen:48 109ms}

    sample "message" => line, "type" => 'mongodb_log', 'tags' => ['mongodb', 'log'] do
      reject { subject["tags"] || [] }.include? "_grokparsefailure"
      insist { subject["message"] } == line
      insist { subject["mongodb_log_type_message"] } == 'command opglpa-api.$cmd command: count { count: "lpaInfo", query: { damage_award: true } } planSummary: COLLSCAN keyUpdates:0 numYields:1 locks(micros) r:183877 reslen:48 109ms'
      insist { subject.timestamp.utc.iso8601 } == "2015-01-05T15:11:21Z"
      insist { subject["mongodb_log_subtype"] } == "conn"
      insist { subject["mongodb_log_conn_number"] } == 108425
      insist { subject["tags"] || [] }.include? "mongodb_slow_query"
      insist { subject["mongodb_log_query_operation"] } == 'command'
      insist { subject["mongodb_log_query_database"] } == 'opglpa-api'
      insist { subject["mongodb_log_query_collection"] } == '$cmd'
      insist { subject["mongodb_log_query_duration_ms"] } == 109
      insist { subject["mongodb_log_query_message"] } == 'command: count { count: "lpaInfo", query: { damage_award: true } } planSummary: COLLSCAN keyUpdates:0 numYields:1 locks(micros) r:183877 reslen:48'
    end

  end


end
