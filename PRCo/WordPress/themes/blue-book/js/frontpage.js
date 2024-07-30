var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";
var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "IA,IA_180x90,IA_180x570");
var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
var ad8 = new BBSiGetAdsWidget("BBSILBContent01", licenseKey, pageName, 1, "IA");
var ad9 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
if(jQuery("html,body").width() <= 600) {
	jQuery("#DigitalEditions").clone(true).css("margin", "20px auto").appendTo("main");
}