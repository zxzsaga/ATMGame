var MongoClient = require('mongodb').MongoClient;
var baseDAO = require('./baseDAO');

function UserDAO(DB) {
    this.DB = DB;
}

UserDAO.prototype.create = function(userName, password, cb) {
    var obj = { _id: userName, password: password };
    baseDAO.create(
        this.DB,
        'Users',
        obj,
        function(err, doc) {
            if (err) {
                return cb(err);
            }
            return cb(err, doc);
        });
};
UserDAO.prototype.getPassword = function(userName, cb) {
    var obj = { _id: userName };
    baseDAO.findOne(
        this.DB,
        'Users',
        obj,
        function(err, doc) {
            if (err) {
                return cb(err);
            }
            return cb(err, doc.password);
        });
};

exports.UserDAO = UserDAO;
