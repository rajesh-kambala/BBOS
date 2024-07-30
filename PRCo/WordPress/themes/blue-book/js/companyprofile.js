		function setupPage() {
			var $sidebar = jQuery(".cat-sidebar2");
			//jQuery("#BBSISQContent01").html("Square Ad 1").height(260).css("border", "1px solid black");
			if(window.screen.width <= 800) {
				jQuery("<div id='BBSIBNContent'></div>").appendTo("body");
				jQuery("#BBSIBNContent01").css("margin-left","5px").css("max-width", "260px").prependTo("article");
				jQuery("#BBSIBNContent01 img").css("max-width", "260px");
				
				var $h2 = jQuery(jQuery(".cat-sidebar2 h2")[0]);
				$h2.insertAfter("#BBSIBNContent01");

				jQuery("#BBSISQContent01").css("max-width", "260px").css("margin", "0 auto");
				jQuery("#BBSISQContent01").parent().insertAfter($h2);

				jQuery("#BBSISQContent03").insertAfter("article table");
				
				if(jQuery("#BBSIBNContent03").length == 0) {
					jQuery("<div id='BBSIBNContent03' style='margin-top:20px;'></div>").insertAfter(jQuery("#BBSISQContent03").next());
					var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
					//jQuery("#BBSIBNContent03").html("leaderboard ad 2");
				}

				if(jQuery("#BBSIBNContent04").length == 0) {
					jQuery("<div id='BBSISQContent04' style='display:none;text-align:center;'></div>").appendTo(".pp-post-secction");
				}
				//jQuery(".pp-post-secction").insertAfter("#BBSISQContent04");
				//jQuery(".widget-title").insertAfter("#BBSISQContent04");
				//jQuery("#BBSIBNContent03").next().next().next().insertAfter(jQuery(".pp-post-secction")[0]);
				
				//jQuery("<div id='BBSISQContent04'></div>").insertAfter("#BBOSPublicProfilesMain_pnlButtonsProduce");
				var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
				//jQuery("#BBSISQContent04").html("Square Ad 3").height(260).css("border", "1px solid black");
				
				//jQuery("<div id='BBSIBNContent'></div>").insertAfter("iframe");
				if(jQuery("#BBSIBNContent04").length == 0) {
					jQuery("<div id='BBSIBNContent04' style='max-width:260px;'></div>").insertAfter("#robly_embed_signup");
					var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
				}
				//setTimeout(function(){jQuery("#BBSISQContent04").insertAfter(jQuery(document.getElementById("CompanyProfile").contentWindow.document.body).find("#robly_embedded_subscribe_form"));}, 100);
				
				//jQuery(jQuery("footer .small-2")[1]).hide();				
				jQuery(".col-sm-7").css("margin-top", "10px");
				jQuery("#BBSISQContent04").css("text-align", "center");
				jQuery(jQuery(".landingpage > div")[0]).hide();
			}
			else {
				jQuery("#MostReadDIV").appendTo($sidebar);
				jQuery(".pp-post-secction li").css("list-style", "none");
				jQuery(".pp-post-secction li > a").css("padding", "10px 5px").css("color", "#050588").css("text-decoration", "none").css("font-family", '"Helvetica Neue",Helvetica,Roboto,Arial,sans-serif').css("font-weight", "400");
				//jQuery(".pp-post-secction").css("margin-left", "0").appendTo($sidebar);
				
				jQuery(".sidebar").css("margin-top", "20px");
				
				//jQuery("#BBSISQContent03").html("Square Ad 2");
				
				if(jQuery("#BBSISQContent04").length == 0) {
					jQuery("<div id='BBSISQContent04'></div>").appendTo(".pp-post-secction");
					var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
					//jQuery("#BBSISQContent04").html("Square Ad 3").height(260).css("border", "1px solid black");
				}

				jQuery("<div id='BBSIBNContent'></div>").appendTo("body");
				if(jQuery("#BBSIBNContent02").length == 0) {
					jQuery("<div id='BBSIBNContent02'></div>").insertBefore("#BBOSPublicProfilesMain_pnlButtonsProduce");
					var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
				}
					
				var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
				//jQuery("#BBSIBNContent03").html("leaderboard ad 2").height(260).css("border", "1px solid black");
			}
			var licenseKey = "BBSIProduceAds";
			var pageName = "ProduceMarketingSite";
			var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
			var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
			//var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "IA,IA_180x90,IA_180x570");
			var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
			//var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
			//var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
			//var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
			var ad8 = new BBSiGetAdsWidget("BBSILBContent01", licenseKey, pageName, 1, "IA");
		}
		setTimeout(setupPage, 100);

