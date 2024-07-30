var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";

if (jQuery("#BBSIOAContent01").length) {
	var ad1 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90");
}

setTimeout(function () {	
	console.log(jQuery("#BBSIOAContent02").length);
	if (jQuery("#BBSIOAContent02").length) {
		var ad2 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
	}
}, 300);
