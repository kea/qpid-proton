/*
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
 */

%module cproton

// provided by SWIG development libraries
%include php.swg

#if SWIG_VERSION < 0x020000
%include compat.swg
#endif

%header %{
/* Include the headers needed by the code in this wrapper file */
#include <proton/engine.h>
#include <proton/message.h>
#include <proton/messenger.h>
#include <proton/url.h>
#include <proton/reactor.h>
#include <proton/sasl.h>
#include <proton/ssl.h>
#include <proton/handlers.h>
#include <proton/types.h>

#define zend_error_noreturn zend_error
%}

%apply (char *STRING, int LENGTH) { (char *STRING, size_t LENGTH) };

// allow pn_link_send/pn_input's input buffer to be binary safe
ssize_t pn_link_send(pn_link_t *transport, char *STRING, size_t LENGTH);
%ignore pn_link_send;
ssize_t pn_transport_input(pn_transport_t *transport, char *STRING, size_t LENGTH);
%ignore pn_transport_input;


// Use the OUTPUT_BUFFER,OUTPUT_LEN typemap to allow these functions to return
// variable length binary data.

%rename(pn_link_recv) wrap_pn_link_recv;
// in PHP:   array = pn_link_recv(link, MAXLEN);
//           array[0] = size || error code
//           array[1] = native string containing binary data
%inline %{
    void wrap_pn_link_recv(pn_link_t *link, size_t maxCount, char **OUTPUT_BUFFER, ssize_t *OUTPUT_LEN) {
        *OUTPUT_BUFFER = emalloc(sizeof(char) * maxCount);
        *OUTPUT_LEN = pn_link_recv(link, *OUTPUT_BUFFER, maxCount );
    }
%}
%ignore pn_link_recv;

%rename(pn_transport_output) wrap_pn_transport_output;
// in PHP:   array = pn_transport_output(transport, MAXLEN);
//           array[0] = size || error code
//           array[1] = native string containing binary data
%inline %{
    void wrap_pn_transport_output(pn_transport_t *transport, size_t maxCount, char **OUTPUT_BUFFER, ssize_t *OUTPUT_LEN) {
        *OUTPUT_BUFFER = emalloc(sizeof(char) * maxCount);
        *OUTPUT_LEN = pn_transport_output(transport, *OUTPUT_BUFFER, maxCount);
    }
%}
%ignore pn_transport_output;

%rename(pn_message_encode) wrap_pn_message_encode;
%inline %{
    void wrap_pn_message_encode(pn_message_t *message, size_t maxCount, char **OUTPUT_BUFFER, ssize_t *OUTPUT_LEN) {
        *OUTPUT_BUFFER = emalloc(sizeof(char) * maxCount);
        *OUTPUT_LEN = maxCount;
        int err = pn_message_encode(message, *OUTPUT_BUFFER, OUTPUT_LEN);
        if (err) {
          *OUTPUT_LEN = err;
          efree(*OUTPUT_BUFFER);
        }
    }
%}
%ignore pn_message_encode;



//
// allow pn_delivery/pn_delivery_tag to accept a binary safe string:
//

%rename(pn_delivery) wrap_pn_delivery;
// in PHP:   delivery = pn_delivery(link, "binary safe string");
//
%inline %{
  pn_delivery_t *wrap_pn_delivery(pn_link_t *link, char *STRING, size_t LENGTH) {
    return pn_delivery(link, pn_dtag(STRING, LENGTH));
  }
%}
%ignore pn_delivery;

// pn_delivery_tag: output a copy of the pn_delivery_tag buffer
//
%typemap(in,numinputs=0) (const char **RETURN_STRING, size_t *RETURN_LEN) (char *Buff = 0, size_t outLen = 0) {
    $1 = &Buff;         // setup locals for holding output values.
    $2 = &outLen;
}
%typemap(argout) (const char **RETURN_STRING, size_t *RETURN_LEN) {
    // This allocates a copy of the binary buffer for return to the caller
    ZVAL_STRINGL($result, *($1), *($2));
}

// Suppress "Warning(451): Setting a const char * variable may leak memory." on pn_delivery_tag_t
%warnfilter(451) pn_delivery_tag_t;
%rename(pn_delivery_tag) wrap_pn_delivery_tag;
// in PHP: str = pn_delivery_tag(delivery);
//
%inline %{
    void wrap_pn_delivery_tag(pn_delivery_t *d, const char **RETURN_STRING, size_t *RETURN_LEN) {
        pn_delivery_tag_t tag = pn_delivery_tag(d);
        *RETURN_STRING = tag.start;
        *RETURN_LEN = tag.size;
    }
%}
%ignore pn_delivery_tag;



//
// reference counter management for passing a context to/from the listener/connector
//

%typemap(in) void *PHP_CONTEXT {
    // since we hold a pointer to the context we must increment the reference count
    Z_ADDREF_PP($input);
    $1 = *$input;
}

// return the context.  Apparently, PHP won't let us return a pointer to a reference
// counted zval, so we must return a copy of the data
%typemap(out) void * {
    *$result = *(zval *)($1);
    zval_copy_ctor($result);
}

%include "proton/cproton.i"
