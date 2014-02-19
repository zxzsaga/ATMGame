var MongoClient = require('mongodb').MongoClient;
var config = require('../../config').config;
var baseDAO = require('./baseDAO');

exports.create = function(userName, password, cb) {
    var obj = { _id: userName, password: password };
    baseDAO.create(
        config.web.DBName,
        'Users',
        obj,
        function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(err, docs);
        });
}

exports.getPassword = function(userName, cb) {
    var obj = { _id: userName };
    baseDAO.findOne(
        config.web.DBName,
        'Users',
        obj,
        function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(err, docs.password);
        });
}
