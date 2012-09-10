/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

#define _POSIX_C_SOURCE 1

#include <proton/driver.h>
#include "../driver-internal.h"
#include "ssl.h"

#include <stdio.h>


/** @file
 * SSL/TLS support API.
 *
 * This file contains stub implementations of the SSL/TLS API.  This implementation is
 * used if there is no SSL/TLS support in the system's environment.
 */



int pn_listener_ssl_server_init(pn_listener_t *listener,
                                const char *certificate_file,
                                const char *private_key_file,
                                const char *password,
                                const char *certificate_db)
{
  if (listener->driver->trace & PN_TRACE_DRV) {
    fprintf(stderr, "pn_listener_ssl_server_init(): SSL not available.\n");
  }
  return -1;
}

int pn_listener_ssl_allow_unsecured_clients(pn_listener_t *listener)
{
  return -1;
}

int pn_connector_ssl_client_init(pn_connector_t *connector,
                                 const char *certificate_db)
{
  if (connector->trace & PN_TRACE_DRV) {
    fprintf(stderr, "pn_connector_ssl_client_init(): SSL not available.\n");
  }
  return -1;
}

int pn_connector_ssl_set_client_auth(pn_connector_t *connector,
                                     const char *certificate_file,
                                     const char *private_key_file,
                                     const char *password)
{
  return -1;
}

int pn_connector_ssl_authenticate_client(pn_connector_t *connector,
                                         const char *trusted_CAs_file)
{
  return -1;
}

int pn_listener_init_ssl_client( pn_listener_t *l, pn_connector_t *c)
{
  return 0;  // support routine - always succeed.
}

void pn_connector_shutdown_ssl( pn_connector_t *c)
{
  // since there's no SSL/TLS, we just close the connector
  pn_connector_close( c );
}


void pn_listener_free_ssl( pn_listener_t *l )
{
}


void pn_connector_free_ssl( pn_connector_t *c )
{
}

int pn_driver_ssl_data_ready( pn_driver_t *d )
{
    return 0;
}
