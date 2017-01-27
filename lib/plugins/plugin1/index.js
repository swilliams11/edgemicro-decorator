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
