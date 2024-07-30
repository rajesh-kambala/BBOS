var __bbsiWidget = null;

// Defines a new class contructor for our widget.  We need
// to know what HTML element we are populating and the
// BBSi key to use to retrieve the data.
function BBSiCompanyAuthWidget(targetHtmlElement, key) {

    // Setup a global variable so other functions 
    // can reference this object instance.
    __bbsiWidget = this;

    // Figure out what our root URL is by looking at the URL used
    // to include this JS file
    var src = document.getElementById("bbsiCompanyAuthWidget").getAttribute('src');
    this.webServiceURL = src.substring(0, src.indexOf("javascript"));

    this.cssFile = "css/CompanyAuthWidget.css";

    this.debug = true;
    this.initialized = false;
    this.jQueryWaitCount = 0;
    this.widgetWaitCount = 0;

    this.targetHtmlElement = targetHtmlElement;
    this.key = key;
    this.loadWidget = loadWidget;


    // If jQuery isn't already loaded,
    // load it.
    if (typeof jQuery == 'undefined') {
        loadJQuery();
    } else {
        initComplete();
    }

    // Now load the widget
    this.loadWidget();
}

// Loads the widget with the appropiate data
function loadWidget() {

    // If the Widget has not yet completed the 
    // initialization, wait a little more.
    if (!this.initialized) {

        this.widgetWaitCount++;
        if (this.widgetWaitCount > 50) {
            if (__bbsiWidget.debug) {
                alert("Unable to load widget");
            }
        } else {
            setTimeout("__bbsiWidget.loadWidget()", 50);
        }

        return;
    }

    var bbsiURL = this.webServiceURL + "WidgetHelper.asmx/GetCompanyAuthWidget";
    var targetHtmlElement = "#" + this.targetHtmlElement;
    $(targetHtmlElement).empty();

    $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: bbsiURL,
        data: { key: "'" + this.key + "'" },
        dataType: "jsonp",
        success: function(msg) {
            $(targetHtmlElement).append(msg.d);
        },
        error: function(xhr, ajaxOptions, thrownError) {
            if (__bbsiWidget.debug) {
                alert(xhr.status + ": " + xhr.statusText);
                alert(thrownError.message);
            }
        }
    });

}

// Loads jQuery by writing out a Script tag to the browser.
// Then sits in a loop (via setTimeout) waiting for jQuery
// to be loaded.
function loadJQuery() {

    if (typeof (jQuery) == 'undefined') {
        document.write("<script type=\"text/javascript\" src=\"" + __bbsiWidget.webServiceURL + "javascript/jquery-1.7.2.min.js\"></script>");
        setTimeout("waitForJQuery()", 50);
    }
}

// Invoked by setTimeout, this function waits
// for the jQuery libary to be loaded.
function waitForJQuery() {
    if (typeof (jQuery) == 'undefined') {

        __bbsiWidget.jQueryWaitCount++;
        if (__bbsiWidget.jQueryWaitCount > 50) {
            if (__bbsiWidget.debug) {
                alert("Unable to load jQuery");
            }
        } else {
            setTimeout("waitForJQuery()", 50);
        }
    } else {
        initComplete();
    }
}

// Indicate we are done initilizing 
// our widget.
function initComplete() {

    jQuery.support.cors = true;
    __bbsiWidget.initialized = true;
}
