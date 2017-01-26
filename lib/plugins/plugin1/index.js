'use strict';
var debug = require('debug')('plugin:plugin1');

var cb = null;
var middleware = function(req, res, next) {
  cb && cb(req,res);
  next();
}
module.exports = {
  init: function(config, logger, stats) {
    return {
      onrequest: function(req, res, next) {
            debug("plugin1 onrequest...");
        middleware(req, res, next);
      }
    };
  },
  setCb: (new_cb) => {
    cb = new_cb;
  }
};
