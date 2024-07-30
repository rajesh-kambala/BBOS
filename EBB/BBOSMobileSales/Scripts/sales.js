function setDropDownClass(controlID) {

    var control = $("#" + controlID);
    if (control.length == 0)
        return;

    control.each(function () {
        control.toggleClass("text-black", true);
    });

    var selectedIndex = $("#" + controlID)[0].selectedIndex;
    if (selectedIndex == 0)
        control.toggleClass("text-placeholder", true);
    else
        control.removeClass("text-placeholder");

    $("#" + controlID + " > option").each(function () {
        $(this).toggleClass("text-black", true);
        $(this).removeClass("text-placeholder");
    });

    control.children(":first").removeClass("text-black");
    control.children(":first").toggleClass("text-placeholder-lightgray", true);
}

function prepDropDownClass(controlID) {
    setDropDownClass(controlID);

    $("#" + controlID).change(function () {
        setDropDownClass(controlID)
    });
}

function AutoCompleteSelected(source, eventArgs) {

    if (eventArgs.get_value() != null) {
        //document.getElementById('QuickFind_txtQuickFind').value = "";
        document.location.href = "CompanyView.aspx?CompanyID=" + eventArgs.get_value();
    }
}

function acePopulated(sender, e) {

    var target = sender.get_completionList();
    target.className = "AutoCompleteFlyout";

    var children = target.childNodes;
    var searchText = sender.get_element().value;

    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        var arrValue = child.innerHTML.split("|");

        var legalName = "";
        if (arrValue[1] != "") {
            legalName = "(" + arrValue[1] + ")<br/>";
        }


        var NodeText = "<span style=\"font-weight:bold;\">" + arrValue[0] + "</span> (" + arrValue[2] + ")<br/>" + legalName + arrValue[3];


        if (i % 2 == 0) {
            child.className = "AutoCompleteFlyoutItem";
        } else {
            child.className = "AutoCompleteFlyoutShadeItem";
        }

        child.innerHTML = NodeText;

        if (child.childNodes[0].tagName == "SPAN") {
            child.childNodes[0]._value = child._value;
        }
    }
}