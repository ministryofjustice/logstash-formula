=======
logstash
=======

Formulas to set up and configure the logstash server, or ship logs into a
central server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


Dependencies
============

.. note::

   This formula has a dependency on the following salt formulas:

   `bootstrap <https://github.com/ministryofjustice/bootstrap-formula>`_

   `utils <https://github.com/ministryofjustice/utils-formula>`_

   `elasticsearch <https://github.com/ministryofjustice/elasticsearch-formula>`_

   `java <https://github.com/ministryofjustice/java-formula>`_

   `redis <https://github.com/ministryofjustice/redis-formula>`_ (the one from
   MoJ, not the saltstack-formulas community repo)

   `python <https://github.com/ministryofjustice/python-formula>`_

   `firewall <https://github.com/ministryofjustice/firewall-formula>`_

   `nginx <https://github.com/ministryofjustice/nginx-formula>`_

Available states
================

.. contents::
    :local:

``server``
----------

Install logstash from the system package manager and start the service. This
has been tested only on Ubuntu 12.04.

Example usage::

    include:
      - logstash.server

Pillar variables
~~~~~~~~~~~~~~~~

- kibana:elasticsearch

  The URL at which the ElasticSearch server can be reached by the client
  browser. The default is to take the current host:port and replace the
  'kibana' part of the hostname with 'elasticsearch' - override this if it is
  not what you want.

- monitoring:enabled (default True)

  Used to configure whether monitoring should be enabled/installed at all.
  It's useful as client side of monitoring is an implicit dependency.

- monitoring:ns (future)
  TODO: Monitoring shall prefix the metrics using this value.


``client``
-----------

Install beaver for the ability to ship logs to the central logstash server over
the redis connection specified in the pillar (with a default of localhost db
#0)

Example usage::

    include:
      - logstash.client

Example pillar::

    beaver:
      redis:
        host: logstash.local
        port: 6379
        db: 0


``logship`` macro
-----------

Macro to ship a given log file with beaver to central logstash server.

The macro has the following arguments:

appshort
  A unique tag for the logfile to ship

logfile
  The path of the log to monitor and ship

type
  The type of the entries in this log file. Shows up as the type field in
  logstash.

  **Default:** ``daemon``

tags
  List of tags to apply to every message.

  **Default:** ``daemon``, ``error``

format
  Format to use when sending to logstash. If you have just a line of text this
  should be ``json`` - if you are already output json to the log then you want
  this to be ``rawjson``

  **Default:** ``json``

Example usage::

    include:
      - logstash.client

    {% from 'logstash/lib.sls' import logship with context %}
    {{ logship('redis-server.log', '/var/log/redis/redis-server.log', 'redis', ['redis','log'], 'json') }}


apparmor
========

This formula includes some simple default apparmor profiles for beaver, and
adds additions to the nginx profile to allow access to kibana and grafana
webroots.

App armor is by default in complain mode which means it allows the action and
logs. To make it deny actions that the beaver profile doesn't cover set the
following pillar::

    apparmor:
      profiles:
        beaver:
          enforce: ''
        # We need to set the same mode on nginx for kibana and grafana too
        nginx:
          encorce: ''



Running Vagrant Tests
============

To run the test suite under Vagrant:

  vagrant up
  vagrant ssh
  # if updates have been made:
  #  salt-call state.highstate
  /vagrant/custom-test/run.sh
