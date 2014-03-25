=======
logstash
=======

Formulas to set up and configure the logstash server.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


Dependencies
============

.. note::

   This formula has a dependency on the following salt formulas:

   `boostrap <https://github.com/ministryofjustice/boostrap-formula>`_

   `utils <https://github.com/ministryofjustice/utils-formula`_

   `elasticsearch <https://github.com/ministryofjustice/elasticsearch-formula>`_

   `java <https://github.com/ministryofjustice/java-formula>`_

   `redis <https://github.com/saltstack-formulas/redis-formula>`_

   `python <https://github.com/ministryofjustice/python-formula>`_

   `supervisor <https://github.com/ministryofjustice/supervisor-formula>`_

   `firewall <https://github.com/ministryofjustice/firewall-formula>`_

Available states
================

.. contents::
    :local:

``init``
----------

Install logstash from the system package manager and start the service. This
has been tested only on Ubuntu 12.04.

Example usage::

    include:
      - logstash
