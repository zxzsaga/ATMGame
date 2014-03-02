// JavaScript Document
var exampleSocket = new WebSocket("http://59.78.44.40:23457", "");

function testfunction1()
{
	//exampleSocket.send($("#tstxt").val());
	exampleSocket.send("aaa");
}

exampleSocket.onmessage = function (event) {
  //$("#aa").html(event.data);
  alert(event.data)
}