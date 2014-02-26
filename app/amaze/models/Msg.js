'use strict';

function Msg(data) {
    this.msgs = dataParse(data);
}

exports.Msg = Msg;

function dataParse(data) {
    data = data.toString();
    var dataArr = data.split('}{');
    if (dataArr.length > 1) {
        dataArr[0] += '}';
        for (var i = 1; i < dataArr.length - 1; i++) {
            dataArr[i] = '{' + dataArr[i] + '}';
        }
        dataArr[dataArr.length - 1] = '{' + dataArr[dataArr.length - 1];
    }
    return dataArr;
}
