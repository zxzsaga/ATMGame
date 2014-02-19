var MongoClient = require('mongodb').MongoClient;

exports.create = function(DB, coll, obj, cb) {
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
    })
}

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
    })
}
