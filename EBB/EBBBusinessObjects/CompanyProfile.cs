/***********************************************************************
***********************************************************************
 Copyright Produce Reporter Co 2007-2011

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Produce Reporter Co is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: CompanyProfile
 Description:	

 Notes:	Created By Sharon Cole on 7/18/2007 3:07:32 PM

***********************************************************************
***********************************************************************/
using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

namespace PRCo.EBB.BusinessObjects
{
    /// <summary>
    /// Container for CompanyProfile information intendeded to be
    /// serialized / deserialized.
    /// </summary>
    [Serializable]
    public class CompanyProfile
    {

        public int SellBrokersPct;
        public int SellWholesalePct;
        public int SellDomesticBuyersPct;
        public int SellExportersPct;
        public int SellSecManPct;
        public int SellCoOpPct;
        public int SellRetailYardPct;
        public int SellHomeCenterPct;
        public int SellOfficeWholesalePct;
        public int SellProDealerPct;
        public int SellStockingWholesalePct;

        public int SrcBuyBrokersPct;
        public int SrcBuyWholesalePct;
        public int SrcBuyShippersPct;
        public int SrcBuyExportersPct;
        public int SrcBuyOfficeWholesalePct;
        public int SrcBuyStockingWholesalePct;
        public int SrcBuyMillsPct;
        public int SrcBuySecManPct;
        public int SrcTakePhysicalPossessionPct;

        public int BkrTakeTitlePct;
        public int BkrTakePossessionPct;
        public int BkrCollectPct;

        public int TrkrDirectHaulsPct;
        public int TrkrTPHaulsPct;
        public int TrkrProducePct;
        public int TrkrOtherColdPct;
        public int TrkrOtherWarmPct;
        public int StorageWarehouses;

        public bool SellBuyOthers;
        public bool ColdStorage;
        public bool RipeningStorage;
        public bool HumidityStorage;
        public bool AtmosphereStorage;
        public bool ColdStorageLeased;
        public bool HAACP;
        public bool QTV;
        public bool Organic;
        public bool TrkrTeams;
        public bool BkrGroundInspections;
        public bool BkrTakeFrieght;
        public bool BkrConfirmation;
        public bool BkrCollectRemitForShipper;

        public string TrkrTrucksOwned;
        public string TrkrTrucksLeased;
        public string TrkrTrailersOwned;
        public string TrkrTrailersLeased;
        public string TrkrPowerUnits;
        public string TrkrReefer;
        public string TrkrDryVan;
        public string TrkrFlatbed;
        public string TrkrPiggyback;
        public string TrkrTanker;
        public string TrkrContainer;
        public string TrkrOther;
        public string SellDomesticAccountTypes;
        public string BkrReceive;
        public string StorageSF;
        public string StorageCF;
        public string StorageBushel;
        public string StorageCarlots;
        public string HAACPCertifiedBy;
        public string QTVCertifiedBy;
        public string OrganicCertifiedBy;
        public string OtherCertification;

        public string StorageCoveredSF;
        public string StorageUncoveredSF;

        public string RailServiceProvider1;
        public string RailServiceProvider2;

    }
}
