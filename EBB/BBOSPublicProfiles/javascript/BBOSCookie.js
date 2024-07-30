var name = "BBSi.BBOSLogin";
var value = "Y";

var expirationDate = new Date();
expirationDate.setDate(expirationDate.getDate() + 14);

var c_value = escape(value) + "; expires=" + expirationDate.toUTCString() + ";path=/";
document.cookie = name + "=" + c_value;
 