var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";

if (jQuery("#BBSIOAContent01").length) {
	var ad1 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90");
}

if (jQuery("#BBSIOAContent02").length) {
	setTimeout(function () {		
		var ad2 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
	}, 750);
}

if (jQuery("#BBSIBNContent03").length) {
	var $bannerAd2 = jQuery("#BBSIBNContent03").clone(true);
	$bannerAd2.css("padding-top", "7px");
	$bannerAd2.attr("id", "BBSIBNContent02");
	var $pars = jQuery("article .entry-content p");
	
	if($pars.length > 1) {
		$bannerAd2.appendTo($pars[1]);
	}
	else {
		$bannerAd2.appendTo($pars[$pars.length - 1]);
	}
}

function fixArticlesMobile() {
	var $squareAdPost = jQuery("#squareAdPost");
	var $bannerAdPost = jQuery("#bannerAdPost");
	var $paras = jQuery("article .entry-content p");
	var idx = 0;
	if($bannerAdPost.length > 0 && $bannerAdPost.parents("article").length > 0) {
		idx++;
	}
	
	if($squareAdPost.length > 0 && $squareAdPost.parents("article").length > 0) {
		return;
	}
	//var $swboc = jQuery("#swboc-82");
	if(document.body.clientWidth < 600) {
		jQuery(jQuery(".SWBOC_Widget")[0]).hide();
		if($paras.length > 1) {
			var $para2 = jQuery($paras[1]);
			var $para2img = $para2.find("img");
			
			if($para2img.length == 0 || $paras.length < 3) {
				if($squareAdPost.length > 0) {
					if($paras.length > 2) {
						$squareAdPost.appendTo($para2);
						$bannerAdPost.appendTo($paras[2+idx]);
					}
					else {
						$bannerAdPost.appendTo($para2);
						$squareAdPost.appendTo($para2);
					}
				}
				else if($bannerAdPost.length > 0) {
					$bannerAdPost.appendTo($para2);
				}
			}
			else if($para2img.length == 1 && $paras.length > 2) {
				if($squareAdPost.length > 0) {
					$squareAdPost.appendTo($para2);
					if($bannerAdPost.length > 0) {
						$bannerAdPost.appendTo($paras[3+idx]);
					}
				}
				else if($bannerAdPost.length > 0) {
					$bannerAdPost.appendTo($paras[3+idx]);
				}
			}
		}
		else if ($paras.length == 1) {
			if($squareAdPost.length > 0) {
				$bannerAdPost.appendTo($paras[0]);
				$squareAdPost.appendTo($paras[0]);
			}
			else if($bannerAdPost.length > 0) {
				$bannerAdPost.appendTo($paras[0]);
			}
		}
		else {
			$squareAdPost.hide();
			$bannerAdPost.hide();
		}
	}
	else if($bannerAdPost.length > 0) {
		if($paras.length > 1) {
			var $para2 = jQuery($paras[1]);
			var $para2img = $para2.find("img");
			
			if($para2img.length == 0 || $paras.length < 3) {
				$bannerAdPost.appendTo($para2);
			}
			else if($para2img.length == 1 && $paras.length > 2) {
				$bannerAdPost.appendTo($paras[2]);
			}
		}
		else if ($paras.length == 1) {
			$bannerAdPost.appendTo($paras[0]);
		}
		else {
			$bannerAdPost.hide();
		}
	}
}

fixArticlesMobile();
jQuery(window).on('resize', fixArticlesMobile);

var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB3");
var ad8 = new BBSiGetAdsWidget("BBSILBContent01", licenseKey, pageName, 1, "IA");