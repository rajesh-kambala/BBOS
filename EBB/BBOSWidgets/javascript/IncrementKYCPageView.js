var postid = "";
$.each($('body').attr('class').split(' '), function (index, className) {
    if (className.indexOf('postid-') === 0) {
        postid = className.slice(7);
    }
});

if(postid != "")
    BBSiIncrementKYCPageView(postid);

function BBSiIncrementKYCPageView(articleID) {
    var src = document.getElementById("bbsiGetAdsWidget").getAttribute('src');
    this.webServiceURL = src.substring(0, src.indexOf("javascript"));
    var bbsiURL = this.webServiceURL + "WidgetHelper.asmx/IncrementKYCPageView";

    $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: bbsiURL,
        data: { ArticleID: "'" + articleID + "'" },
        dataType: "jsonp",
        success: function (msg) {
            if (this.debug) {
                alert('incremented ' + msg.d);
            }
        },
        error: function (xhr, ajaxOptions, thrownError) {
            if (this.debug) {
                alert(xhr.status + ": " + xhr.statusText);
                alert(thrownError.message);
            }
        }
    });
}