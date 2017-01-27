'use strict';
var debug = require('debug')('plugin:plugin2');

module.exports = {
  init: function(config, logger, stats) {
    return {
      onrequest: function(req, res, next) {
       debug('plugin-2: onrequest');
       next();
     },

     ondata_request: function(req, res, data, next) {
       debug('plugin-2: ondata_request ' + data);
       next(null, data);
     },

     onend_request: function(req, res, data, next) {
       debug('plugin-2: onend_request ' + data);
       next(null, data);
     },

     onclose_request: function(req, res, next) {
       debug('plugin-2: onclose_request ');
       next(null, data);
     },

     onerror_request: function(req, res, data, next) {
       debug('plugin-2: onerror_request ' + data);
       next(null, data);
     },

     //RESPONSE
     onresponse: function(req, res, data, next) {
       debug('plugin-2: onresponse ' + data);
       next(null, data);
     },

     ondata_response: function(req, res, data, next) {
       debug('plugin-2: ondata_response ' + data);
       next(null, data);
     },

     onend_response: function(req, res, data, next) {
       debug('plugin-2: onend_response ' + data);
       next(null, data);
     },

     onclose_response: function(req, res, next) {
       debug('plugin-2: onclose_response');
       next(null, data);
     },

     onerror_response: function(req, res, data, next) {
       debug('plugin-2: onerror_response ' + data);
       next(null, data);
     }
    };
  }
};
