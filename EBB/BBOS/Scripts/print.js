function NoBorder(obj) {
    var ele = document.getElementById(obj);
    if(ele != null)
        ele.style.setProperty('border-width', '0');
}

function Hide(obj) {
    var ele = document.getElementById(obj);
    if (ele != null)
        ele.classList.add('hidden');
}

function Show(obj) {
    var ele = document.getElementById(obj);
    if (ele != null)
        ele.classList.remove('hidden');
}

function HideButtons() {
    var elements = document.getElementsByTagName("*");
    if (elements != null) {
        for (var i = 0, element; element = elements[i++];) {
            if (element.id.indexOf("btn") != -1)
                element.classList.add('hidden');
        }
    }
}

function HideAnchorTags() {
    $('a').tagRemover();
}

function HideUncheckedRows() {
    var elements = document.getElementsByName("cbCompanyID");
    if (elements !== null) {
        for (var i = 0, element; element = elements[i++];) {
            if (element.type == "checkbox" && !element.checked) {
                $(element).closest("tr").hide();
            }
        }
    }
}

function AddPanel(panel) {
    if (panel != null)
        return panel.innerHTML;
    else
        return "";
}

function printContent(el){
    var restorepage = $('body').html();
    var printcontent = $('#' + el).clone();
    $('body').empty().html(printcontent);
    window.print();
    $('body').html(restorepage);
}

(function ($) {
    $.fn.tagRemover = function () {
        return this.each(function () {
            var $this = $(this);
            var text = $this.text();
            $this.replaceWith(text);
        });
    }
})(jQuery);
