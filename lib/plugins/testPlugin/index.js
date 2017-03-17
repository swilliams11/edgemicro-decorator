'use strict';
var debug = require('debug')('plugin:plugin2');

module.exports = {
  init: function(config, logger, stats) {
    return {
      onrequest: function(req, res, next) {
       debug('testPlugin: onrequest');
       next();
     },

     ondata_request: function(req, res, data, next) {
       debug('testPlugin: ondata_request ' + data);
       next(null, data);
     },

     onend_request: function(req, res, data, next) {
       debug('testPlugin: onend_request ' + data);
       next(null, data);
     },

     onclose_request: function(req, res, next) {
       debug('testPlugin: onclose_request ');
       next(null, data);
     },

     onerror_request: function(req, res, data, next) {
       debug('testPlugin: onerror_request ' + data);
       next(null, data);
     },

     //RESPONSE
     onresponse: function(req, res, data, next) {
       debug('testPlugin: onresponse ' + data);
       res.setHeader('x-testPlugin', 'testPlugin');
       next(null, data);
     },

     ondata_response: function(req, res, data, next) {
       debug('testPlugin: ondata_response ' + data);
       next(null, data);
     },

     onend_response: function(req, res, data, next) {
       debug('testPlugin: onend_response ' + data);
       next(null, data);
     },

     onclose_response: function(req, res, next) {
       debug('testPlugin: onclose_response');
       next(null, data);
     },

     onerror_response: function(req, res, data, next) {
       debug('testPlugin: onerror_response ' + data);
       next(null, data);
     }
    };
  }
};
