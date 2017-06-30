#!/usr/bin/env python
import argparse
import json
import logging
import sys
from datetime import datetime
from OpenSSL import crypto as c
from docker.client import Client

class StunnelScanner(object):
    """
    Class to scan containers for stunnel env variables
    """ 
    def __init__(self,
                 log_file="/var/log/cron.log",
                 log_level="INFO"):
        self.setup_logging(
            logger_name="stunnel_scanner",
            log_file=log_file,
            log_level=log_level)


    def run(self,
            ssl_env_name='STUNNEL_SSL'):
        """
           Run a container scan for a variable containing a certificate env dictionary

            Args:
                ssl_env_name(string): The string containing the certificate env
        """
        cli = Client(base_url='unix://var/run/docker.sock')
        for container in cli.containers():
          container_details = cli.inspect_container(container.get('Id'))
          container_envs = container_details.get('Config').get('Env')
          env_ssl = [ env for env in container_envs if ssl_env_name in env]
          if len(env_ssl) > 0:
            env_cert = env_ssl[0].split('=', 1)[1]
            env_json = json.loads(env_cert)
            raw_ssl = env_json.get('cert')
            cert = c.load_certificate(c.FILETYPE_PEM, raw_ssl)
            not_after = cert.get_notAfter()
            not_after_date = self.get_cert_time(not_after)
            has_expired = cert.has_expired()
            signature_algorithm = cert.get_signature_algorithm()
            self.logger.info("Found stunnel container envs", 
                             extra={'notAfter': '{}'.format(not_after),
                                    'notAfterDate': '{}'.format(not_after_date),
                                    'hasExpired': '{}'.format(has_expired),
                                    'containerId': '{}'.format(container.get('Id')),
                                    'signatureAlgorithm': '{}'.format(signature_algorithm)})
    
    def get_cert_time(self, cert_time):
        """
        Translate a time

        Args:
            cert_time(string): Certificate time to translate

        Return:
            (string): Format date string
        """
        dt_str = datetime.strptime(cert_time,"%Y%m%d%H%M%SZ").isoformat()
        return dt_str

    def setup_logging(self,
                      log_level='INFO',
                      log_file=None,
                      logger_name="main"):
        """
        Setup the logging
        """
        logging_format_str = ('{"timestamp": "%(asctime)s",'
                              '"name": "%(name)s", '
                              '"level": "%(levelname)s", '
                              '"level_no": %(levelno)s, '
                              '"message": "%(message)s", '
                              '"notAfter": "%(notAfter)s", '
                              '"notAfterDate": "%(notAfterDate)s", '
                              '"hasExpired": "%(hasExpired)s", '
                              '"containerId": "%(containerId)s", '
                              '"signatureAlgorithm": "%(signatureAlgorithm)s" '
                              '}')

        logging.basicConfig(
            format=logging_format_str,
            filename=log_file,
            level=log_level)
        # Set up the logging
        logging.basicConfig(format=logging_format_str,
                            level=logging.getLevelName(log_level))
        self.logger = logging.getLogger(logger_name)
        logging.getLogger("requests").setLevel(logging.WARNING)
        logging.getLogger('boto').setLevel(logging.CRITICAL)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description=('Associate instances with an EIP from a supplied list')
    )
    parser.add_argument('--log-level',
                        dest='log_level',
                        help=('Set the logging level, DEBUG/INFO/WARNING/ERROR/CRITICAL'),
                        default='INFO'
                        )
    parser.add_argument('--log-file',
                        dest='log_file',
                        help=('File to log to.'),
                        default=None
                        )
    args = parser.parse_args()
    scanner = StunnelScanner(log_file=args.log_file, log_level=args.log_level)
    scanner.run()
    sys.exit(0)

