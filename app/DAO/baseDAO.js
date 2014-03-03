'use strict';

var MongoClient = require('mongodb').MongoClient;

exports.insert = function(DB, coll, obj, cb) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            return cb(err);
        }
        var collection = db.collection(coll);
        collection.insert(obj, function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(null, docs);
        });
    });
};
exports.findOne = function(DB, coll, obj, cb) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            return cb(err);
        }
        var collection = db.collection(coll);
        collection.findOne(obj, function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(null, docs);
        });
    });
};
exports.find = function(DB, coll, obj, cb) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            return cb(err);
        }
        var collection = db.collection(coll);
        collection.find(obj, { limit: 10 }, function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(null, docs);
        });
    });
};
exports.update = function(DB, coll, obj, update, cb) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            return cb(err);
        }
        var collection = db.collection(coll);
        collection.update(obj, update, function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(null, docs);
        });
    });
};
exports.remove = function(DB, coll, obj, cb) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            return cb(err);
        }
        var collection = db.collection(coll);
        collection.remove(obj, function(err, docs) {
            if (err) {
                return cb(err);
            }
            return cb(null, docs);
        });
    });
};
