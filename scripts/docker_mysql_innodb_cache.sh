#!/bin/bash
# defaults for wheezy/jessie
# query_cache_limit       = 1M
# query_cache_size        = 16M
# * InnoDB
#key_buffer              = 16M
#max_allowed_packet      = 16M



# Desirables
# if ACID compliance is required of the DB, this must be 2
# setting zero is pragmatic-- improves performance
# but causes innodb to sync/flush only about once per second
innodb_flush_log_at_trx_commit = 0

innodb_lock_wait_timeout = 180
innodb_support_xa = 0
innodb_file_per_table = 1
innodb_flush_method = O_DIRECT

# zero is "Automatic" for thread concurrency 
# which is reasonable in most cases. 
innodb_thread_concurrency = 0

# do not use hostnames in GRANTs
skip-name-resolve
