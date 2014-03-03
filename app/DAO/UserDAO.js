var MongoClient = require('mongodb').MongoClient;
var baseDAO = require('./baseDAO');

function UserDAO(DB) {
    this.DB = DB;
}

UserDAO.prototype.create = function(userName, password, cb) {
    var obj = {
        _id: userName,
        password: password,
        registerAt: new Date()
    };
    baseDAO.insert(
        this.DB,
        'Users',
        obj,
        cb
    )
};
UserDAO.prototype.findOne = function(userName, cb) {
    var obj = { _id: userName };
    baseDAO.findOne(
        this.DB,
        'Users',
        obj,
        cb
    );
};
UserDAO.prototype.update = function(userName, password, cb) {
    var obj = { _id: userName };
    var update = { $set: { password: password} };
    baseDAO.update(
        this.DB,
        'Users',
        obj,
        update,
        cb
    );
};

exports.UserDAO = UserDAO;
