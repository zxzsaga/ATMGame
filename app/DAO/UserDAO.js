var MongoClient = require('mongodb').MongoClient;

var dbName = require(process.env.PWD + '/app/config').DBNAME;

exports.createUser = function(userName) {
    MongoClient.connect(dbName, function(err, db) {
        if (err) {
            throw err;
        }
        var collection = db.collection('Users');
        collection.insert({ name: userName }, function(err, docs) {
            if (err) {
                throw err;
            }
            console.log('Insert User: ' + docs);
        });
    })
}
