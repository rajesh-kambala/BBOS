// create gloabal references to things we'll lookup often
var gtblAddressTypes = null;

var ghdnSelectedCommodityIds = null;
var ghdnPublishedCommodityIds = null;
var ghdnCommodityAttributes = null;

var gSelectedRow = null;
var gSelectedCommodityCodeTD = null;

var garrSearchMatchRows = new Array();
var gsPrevSearchValue = new String("");
var giCurrentMatchRow = 0;


function cursorWait()
{
    document.body.style.cursor = "wait";
}
function cursorPointer()
{
    document.body.style.cursor = "pointer";
}
function cursorDefault()
{
    document.body.style.cursor = "default";
}

function save()
{
    document.all("hdn_Action").value = "save";
    document.EntryForm.submit();
}


function clearSelectedCommodityCode()
{
    if (gSelectedCommodityCodeTD != null)
        gSelectedCommodityCodeTD.className = 'Unselected';
    gSelectedCommodityCodeTD = null;
}
function selectCommodityCode(item)
{
    if (gSelectedCommodityCodeTD != item)
    {
        clearSelectedCommodityCode();
        gSelectedCommodityCodeTD = item;
        item.className = 'Selected';
        lId = item.id.substring("td_selectcomm_".length);
        refreshSelectedAttributes();
        rowCommodity = gtblCommodity.all("_PRCMRow_" + lId);
        makeRowVisible(rowCommodity);
        bringRowIntoView(rowCommodity);
    }
}


function mouseovercheckbox(item)
{
    if (item.Checked == "on")
        item.src = "/CRM/Img/prco/smallcheckfilledover.gif";
    else
        item.src = "/CRM/Img/prco/smallcheckemptyover.gif";
}
function mouseoutcheckbox(item)
{
    if (item.Checked == "on")
        item.src = "/CRM/Img/prco/smallcheckfilled.gif";
    else
        item.src = "/CRM/Img/prco/smallcheckempty.gif";
}

function toggleCB_SelectType(item)
{
    if (item.Checked == "on")
    {
        item.Checked = "off";
        item.src = "/CRM/Img/prco/smallcheckempty.gif";
//        removeSelectedAttribute(item);
    }
    else
    {
        item.Checked = "on";
        item.src = "/CRM/Img/prco/smallcheckfilled.gif";
//        addSelectedAttribute(item);
    }
}
/*
function removeSelectedAttribute(item)
{
    if (gSelectedCommodityCodeTD == null)
    { 
        // shouldn't be able to get here.
        return;
    }
    if (ghdnCommodityAttributes == null)
        ghdnCommodityAttributes = document.all("hdn_CommodityAttributes");
    var sValue = ghdnCommodityAttributes.value;
    var iCommId = gSelectedCommodityCodeTD.CommodityId;
    // "_imgchkAttr_"
    var iAttrId = item.AttrId;
    sSearch = "<" + iCommId + ">";
    ndxStart = sValue.indexOf(sSearch);
    if ( ndxStart > -1)
    {
        ndxEnd = sValue.indexOf("<", ndxStart+ sSearch.length);
        if (ndxEnd == -1)
            ndxEnd = sValue.length;
        sAttrValue = "," + sValue.substring(ndxStart+sSearch.length, ndxEnd)+ ",";
        // remove the current item from the list
        sRemoveSearch = ","+iAttrId+",";
        ndxRemove = sAttrValue.indexOf(sRemoveSearch);
        sAttrValue = sAttrValue.substring(0, ndxRemove) +  sAttrValue.substring(ndxRemove + sRemoveSearch.length-1, sAttrValue.length) ;  
        if (sAttrValue == ",")
        {
            sAttrValue = "";
        }
        else 
            sAttrValue = sSearch + sAttrValue.substring(1, sAttrValue.length -1);
        ghdnCommodityAttributes.value = sValue.substring(0,ndxStart) + sAttrValue + sValue.substring(ndxEnd);
    }

}
function addSelectedAttribute(item)
{
    if (gSelectedCommodityCodeTD == null)
    { 
        // shouldn't be able to get here.
        return;
    }
    if (ghdnCommodityAttributes == null)
        ghdnCommodityAttributes = document.all("hdn_CommodityAttributes");
    var sValue = ghdnCommodityAttributes.value;
    var iCommId = gSelectedCommodityCodeTD.CommodityId;
    // "_imgchkAttr_"
    var iAttrId = item.AttrId;
    sSearch = "<" + iCommId + ">";
    ndxStart = sValue.indexOf(sSearch);
    if ( ndxStart > -1)
    {
        ndxEnd = sValue.indexOf("<", ndxStart+ sSearch.length);
        if (ndxEnd == -1)
            ndxEnd = sValue.length;
        sAttrValue = sValue.substring(ndxStart, ndxEnd);
        sAttrValue = sAttrValue +  "," + iAttrId ;  
        ghdnCommodityAttributes.value = sValue.substring(0,ndxStart) + sAttrValue + sValue.substring(ndxEnd);
    }
    else
    {
        sAttrValue = sSearch + iAttrId;
        ghdnCommodityAttributes.value = sValue + sAttrValue;
    }    

}
function removeCommodityAttributes(iCommId)
{
    if (ghdnCommodityAttributes == null)
        ghdnCommodityAttributes = document.all("hdn_CommodityAttributes");
    var sValue = ghdnCommodityAttributes.value;
    sSearch = "<" + iCommId + ">";
    ndxStart = sValue.indexOf(sSearch);
    if ( ndxStart > -1)
    {
        ndxEnd = sValue.indexOf("<", ndxStart+ sSearch.length);
        if (ndxEnd == -1)
            ndxEnd = sValue.length;
        sAttrValue = sValue.substring(0, ndxStart) +  sValue.substring(ndxEnd) ;  
        ghdnCommodityAttributes.value = sAttrValue;
    }
    

}
*/

