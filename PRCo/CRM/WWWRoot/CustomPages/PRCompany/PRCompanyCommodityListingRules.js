/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

   This file contains the business rules for the listing of a commodity
   code along with any growing method and attribute combinations


***********************************************************************
***********************************************************************/
function getCommodityListing(arrCommodityNames, arrCommodityCodes, nLevel, sGMAbbr, sAttrAbbr, bAttrPlaceAfter)
{
    //alert(arrCommodityCodes[0]+ "-" + arrCommodityCodes[1]+ "-" + arrCommodityCodes[2]);
    // the three elements required to form the string are commodity, growing method, and attribute
    var sCommodityString = "";
    // get the commodity structures string resolved; this is based upon the level
    if (nLevel <= 3)
    {
        sCommodityString = arrCommodityCodes[nLevel-1];
    }
    else if (nLevel == 4)
    {
        // if the variety group(L4) = commodity(L3) just show the variety group
        // otherwise show the concatenation

        // remember these are indexes( i.e Level-1)
        if (arrCommodityNames[3] == arrCommodityNames[2])
            sCommodityString = arrCommodityCodes[3];
        else    
            sCommodityString = arrCommodityCodes[3] + (arrCommodityCodes[2]).toLowerCase();
            
    }
    else if (nLevel == 5)
    {
        // if the variety(L5) determine if there is a variety Group(L4). if so, compare the 
        // L5 to the L4 and the commodity(L3) values.  If they are all different, concatenate them
        // all. If the L5 != L3 and there is no L4, then display L4L3(lowercase)
        
        // remember these are indexes( i.e Level-1)
        //    alert(arrCommodityNames[1]+"/"+arrCommodityNames[1]+"/"+arrCommodityNames[2]+"/"+arrCommodityNames[3]+"/"+arrCommodityNames[4]+"/"+arrCommodityNames[5]);
        if (arrCommodityNames[3] == "") // no L4
        {
            //alert(arrCommodityNames[4] + " == " + arrCommodityNames[2]);
            if (arrCommodityNames[4] == arrCommodityNames[2])
                sCommodityString = arrCommodityCodes[4];
            else    
                sCommodityString = arrCommodityCodes[4] + (arrCommodityCodes[2]).toLowerCase();
        }
        else
        {
                if (arrCommodityNames[4] == arrCommodityNames[2] || arrCommodityNames[3] == arrCommodityNames[2])
                    sCommodityString = arrCommodityCodes[3] + (arrCommodityCodes[2]).toLowerCase();
                else    
                    sCommodityString = arrCommodityCodes[4] 
                                     + (arrCommodityCodes[3]).toLowerCase() 
                                     + (arrCommodityCodes[2]).toLowerCase();
        }            
    }
    else if (nLevel == 6)
    {
        sCommodityString = arrCommodityCodes[5] 
                    + (arrCommodityCodes[4]).toLowerCase() 
                    + (arrCommodityCodes[3]).toLowerCase()
                    + (arrCommodityCodes[2]).toLowerCase();
    
    }
    
    if (sAttrAbbr != null)
    {
        if (bAttrPlaceAfter == true)
            sCommodityString += sAttrAbbr ; 
        else
            sCommodityString = sAttrAbbr + sCommodityString.toLowerCase();
    }
    // the GrowingMethod String just gets concatenated
    if (sGMAbbr != null) {
        sCommodityString = sGMAbbr + sCommodityString.toLowerCase();
    }
    
    
    return  sCommodityString;
        
}
