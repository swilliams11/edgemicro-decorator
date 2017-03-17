/* jslint node: true */
'use strict';

var apickli = require('apickli');

module.exports = function() {
    // cleanup before every scenario
    this.Before(function(scenario, callback) {
        this.apickli = new apickli.Apickli('http', 'rest-servicetest.local.pcfdev.io');
        this.apickli.storeValueInScenarioScope("edgeAuthTokenEndpoint", "http://edgeDomain:9001/edgemicro-auth/token");
        callback();
    });

    this.When(/^I POST domain (.*)$/, function (resource, callback) {
        this.apickli.postdomain(resource, function (error, response) {
            if (error) {
                callback(new Error(error));
            }

            callback();
        });
    });
};
