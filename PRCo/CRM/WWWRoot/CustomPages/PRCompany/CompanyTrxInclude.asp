<%
    /* ****************************************************************************
     * This block provides some base transaction determination for companies.
     *   * prior to this block being invoked the comp_companyid must be set
     * 
     * Two values are made available to the page including this file:
     *   iTrxStatus: the status of the transaction as TRX_STATUS_... values
     *   recTrx: the accpac transaction record, if present
     *   blkTrxHeader: the trx header block to display at the top of the page; this
     *                 can be included into any accpac container
     * ***************************************************************************/
    // determine the transaction status for this company
    var user_UserId;
    var TRX_STATUS_NONE = 0;
    var TRX_STATUS_LOCKED = 1;
    var TRX_STATUS_EDIT = 2;
    var iTrxStatus = TRX_STATUS_NONE;
    recTrx = eWare.FindRecord('PRTransaction','prtx_status=\'O\' AND prtx_companyid=' + comp_companyid);
    var sTxnStatus = recTrx.prtx_TransactionId;
    //Response.Write("<br>sTxnStatus: [" + sTxnStatus + "]");
    if (!isEmpty(sTxnStatus))
    {
        if ( isEmpty(user_UserId) )
        {
            user_UserId = eWare.getContextInfo('User', 'User_UserId');
            //Response.Write("<br>User: [" + user_UserId + "]");
        }
        recTrxUser = eWare.FindRecord('User', 'User_UserId='+recTrx.prtx_CreatedBy);
        if (recTrx.prtx_CreatedBy == user_UserId)
            iTrxStatus = TRX_STATUS_EDIT;
        else
            iTrxStatus = TRX_STATUS_LOCKED;
    }
    //Response.Write("<br>iTrxStatus: [" + iTrxStatus + "]");
        
    var blkTrxHeader = eWare.GetBlock('content');
    var sMsg = "";
    if (iTrxStatus == TRX_STATUS_EDIT)
        sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You have this company open for editing. Close the current transaction to allow others to edit this company.</td></tr></table> ";
    else if (iTrxStatus == TRX_STATUS_LOCKED)
        sMsg = "<table width=\"100%\" class=\"ErrorContent\"><tr><td>This Company is currently Locked by " + recTrxUser.user_FirstName + " " + recTrxUser.user_LastName + ".</td></tr></table> ";

    blkTrxHeader.contents = sMsg;

    // Finally, if the eWare mode is edit and the trx is not open; set it to view
    if (eWare.Mode == Edit && iTrxStatus != TRX_STATUS_EDIT)
        eWare.Mode = View;
%>