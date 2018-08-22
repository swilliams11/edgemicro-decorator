/**
Copyright 2018 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
**/

'use strict';

var debug = require('debug')('plugin:plugin1');

module.exports = {
  init: function(config, logger, stats) {
    return {
      onrequest: function(req, res, next) {
       debug('plugin-1: onrequest');
       next();
     },

     ondata_request: function(req, res, data, next) {
       debug('plugin-1: ondata_request ' + data);
       next(null, data);
     },

     onend_request: function(req, res, data, next) {
       debug('plugin-1: onend_request ' + data);
       next(null, data);
     },

     onclose_request: function(req, res, next) {
       debug('plugin-1: onclose_request');
       next(null, data);
     },

     onerror_request: function(req, res, data, next) {
       debug('plugin-1: onerror_request' + data);
       next(null, data);
     },

     //RESPONSE
     onresponse: function(req, res, data, next) {
       debug('plugin-1: onresponse ' + data);
        res.setHeader('x-plugin1', 'plugin1');
       next(null, data);
     },

     ondata_response: function(req, res, data, next) {
       debug('plugin-1: ondata_response ' + data);
       next(null, data);
     },

     onend_response: function(req, res, data, next) {
       debug('plugin-1: onend_response ' + data);
       next(null, data);
     },

     onclose_response: function(req, res, next) {
       debug('plugin-1: onclose_response');
       next(null, data);
     },

     onerror_response: function(req, res, data, next) {
       debug('plugin-1: onerror_response ' + data);
       next(null, data);
     }
    };
  }
};
