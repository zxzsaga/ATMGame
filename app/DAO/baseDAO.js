var MongoClient = require('mongodb').MongoClient;

exports.create = function(DB, coll, obj) {
    MongoClient.connect(DB, function(err, db) {
        if (err) {
            throw err;
        }
        var collection = db.collection(coll);
        collection.insert(obj, function(err, docs) {
            if (err) {
                throw err;
            }
            return docs;
        });
    })
}
