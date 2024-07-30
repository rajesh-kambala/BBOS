var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";
jQuery(document).ready(function(){
	jQuery(['#toggle-search', '#close-search']).each(function(i,v){
		jQuery(v).on('click', function(){
			jQuery('.site-search').toggle('slow');
		});
	});
	jQuery('#search_date').on('change', function(){
		var date = jQuery(this).val();
		var date_array = date.split('-');
		var monthnum = date_array[1];
		var year = date_array[0];
		var day = date_array[2];
		jQuery('#year_search').val(year);
		jQuery('#month_search').val(monthnum);
		jQuery('#day_search').val(day);
	});
	var megamenu = new Foundation.AccordionMenu(jQuery('#menu-hamburger-links'), '');
	var accordion = new Foundation.Accordion(jQuery('.accordion-linkitems'), {'multi-expand': true, 'allow-all-closed': true});
	jQuery('.mega_menu_toggler').on('click', function(){
		jQuery('.accordion-menu-section').toggle('slow');
	});
	jQuery("#main .pinned_articles .post-sub-section").each(function() {
		var $this = jQuery(this);
		$this.find(".large-9").css("width", "100%");
		var $img = $this.find(".large-3 img");
		$img.parent().hide();
		$img.css("width", "50px");
		$img.css("float", "right");
		var $h3 = jQuery(this).find(".post_title");
		$h3.css("height", "100%");
		$h3.css("max-height", "7rem");
		$img.prependTo($h3);
	});
	
	jQuery(".print").click(function(event){
		event.preventDefault();
		setTimeout(function() { // wait until all resources loaded 
			window.focus(); // necessary for IE >= 10
			window.print(); // change window to winPrint
		}, 250);
	});
});

function robly_recaptcha_callback(token) {
	var email = jQuery("#DATA0").val();
	if (!is_valid_email_address(email)) {
		alert("Please enter a valid email address.");
		return false;
	}
	var f = jQuery("#robly_embedded_subscribe_form");
	f.submit();
}

function is_valid_email_address(emailAddress) {
      var pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);

      return pattern.test(emailAddress);
}
function setSquareAd2() {
	 var $squareAd2 = jQuery("#BBSISQContent02");
	 var $squareAd1 = jQuery("#BBSISQContent01");
	 if($squareAd2.length > 0 && $squareAd1.length > 0) {
		 if($squareAd1.html() == "") {
			 setTimeout(setSquareAd2, 100);
		 }
		 else {
			$squareAd2.html($squareAd1.html());
		 }
	 }
}
setSquareAd2();
function hideMissingAds() {
	setTimeout(function() {
		for(var idx = 1; idx < 6; idx++) {
			var $obj = jQuery("#BBSIBNContent0" + idx +", article #BBSIBNContent0" + idx);
			var len = $obj.length;
			if(len > 0) {
				if(len == 1 && $obj.html() == "") {
					$obj.hide();
				}
				else {
					for(var ix = 0; ix < len; ix++) {
						var $ob = jQuery($obj[ix]);
						if($ob.html() == "") $ob.hide();
					}
				}
			}
		}
	}, 1000);
}
function setFindCompaniesBanners() {
	jQuery("<div id=\"BBSIBNContent01\" style=\"position: relative;\"></div>").insertBefore("#main article");
	jQuery("<div id=\"BBSIBNContent02\" style=\"position: relative;\"></div>").insertAfter("#main article .entry-content p:nth-child(2)");
	jQuery("<div id=\"BBSISQContent02\" style=\"margin-top: 10px; position: relative;\"></div>").insertBefore("#BBSIOAContent01");
	jQuery("<div id=\"BBSISQContent03\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter("#BBSIOAContent01");
	$bannerad1 = jQuery("#BBSIBNContent01");
	$bannerad2 = jQuery("#BBSIBNContent02");
	$bannerad3 = jQuery("#BBSIBNContent03");
	$squaread2 = jQuery("#BBSISQContent02");
	$squaread3 = jQuery("#BBSISQContent03");
	var $ad1 = jQuery("#BBSICAContent01");
	if($bannerad1.length > 0) var ad1 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
	if($bannerad2.length > 0) var ad2 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
	if($squaread2.length > 0) var ad3 = new BBSiGetAdsWidget("BBSISQContent02", licenseKey, pageName, 1, "PMSHPSQ2");
	if($squaread3.length > 0) var ad6 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ3");
	if($ad1.length > 0) var ad31 = new BBSiGetAdsWidget("BBSICAContent01", licenseKey, pageName, 1, "PMSHPSQ");
	if(window.screen.width <= 800) {
		$ad1.insertBefore(jQuery(".entry-content p")[0]);
		$squaread2.insertAfter(jQuery(".entry-content p")[0]);
		$bannerad2.insertAfter(jQuery(".entry-content p")[1]);
		jQuery("#BBSISQContent03").insertAfter(jQuery(".entry-content p")[3]);
	}
	$bannerad3.insertAfter(jQuery("iframe"));
	if($bannerad3.length > 0) var ad4 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB3");
}
function setKnowYourCommodityBanners() {
	$bannerad1 = jQuery("#BBSIBNContent01");
	var $kycad1 = jQuery("#BBSIKYCContent01");
	var $kycad2 = jQuery("#BBSIKYCPMSHPB01");
	if($kycad1.length > 0) var ad7 = new BBSiGetAdsWidget("BBSIKYCContent01", licenseKey, pageName, 1, "PMSHPSQ");
	if($kycad2.length > 0) var ad8 = new BBSiGetAdsWidget("BBSIKYCPMSHPB01", licenseKey, pageName, 1, "PMSHPB");
	$bannerad1.css("margin-top", "0").insertBefore("#main article");
	$kycad2.css("margin-top", "0").css("text-align", "center").insertBefore("#main article");
	jQuery("<div id=\"BBSIBNContent02\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter(".entry-content .grid-x");
	jQuery("<div id=\"BBSIBNContent03\" style=\"margin-top: 10px; position: relative;\"></div>").appendTo(".entry-content");
	jQuery("<div id=\"BBSISQContent02\" style=\"position: relative;\"></div>").insertBefore("#swboc-33");
	jQuery("<div id=\"BBSISQContent03\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter("#otherAds1");
	$bannerad2 = jQuery("#BBSIBNContent02");
	$bannerad3 = jQuery("#BBSIBNContent03");
	$squaread2 = jQuery("#BBSISQContent02");
	$squaread3 = jQuery("#BBSISQContent03");
	if($bannerad1.length > 0) var ad1 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
	if($bannerad2.length > 0) var ad2 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
	if($bannerad3.length > 0) var ad3 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB3");
	if($squaread2.length > 0) var ad4 = new BBSiGetAdsWidget("BBSISQContent02", licenseKey, pageName, 1, "PMSHPSQ2");
	if($squaread3.length > 0) var ad6 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ3");
	if(window.screen.width <= 800) {
		$kycad1.insertBefore(jQuery(".entry-content p")[0]);
		$squaread2.insertAfter(jQuery(".entry-content p")[0]);
		$bannerad2.insertAfter(jQuery(".entry-content p")[1]);
		$squaread3.insertAfter($bannerad2);
		$bannerad3.insertAfter(jQuery(".entry-content p")[2]);
		
		jQuery("#primary .desktop-sidebar").insertBefore("footer");
	}
}
function checkForDuplication($object) {
	var id = $object.attr("id");
	if(!id) return;
	$visibleObjects = jQuery("div:visible");
	if($visibleObjects.length > 1) {
		idx = 0;
		$visibleObjects.each(function() {
			var $this = jQuery(this);
			if($this.attr("id") == id) {
				console.log(id);
				if(idx == 0) {
					idx++;
					return;
				}
				$this.height(0);
				$this.hide();
				idx++;
			}
		});
	}
}

jQuery(function() {
	setTimeout(function() {
		var $bannerad1 = jQuery("#BBSIBNContent01");
		var $bannerad2 = jQuery("#BBSIBNContent02");
		var $bannerad3 = jQuery("#BBSIBNContent03");
		var $squaread1 = jQuery("#BBSISQContent01");
		var $squaread2 = jQuery("#BBSISQContent02");
		var $squaread3 = jQuery("#BBSISQContent03");
		var $squaread4 = jQuery("#BBSISQContent04");
		var $squaread5 = jQuery("#BBSISQContent05");
		hideMissingAds();
		setTimeout(function(){
			checkForDuplication($bannerad1);
			checkForDuplication($bannerad2);
			checkForDuplication($bannerad3);
			checkForDuplication($squaread1);
			checkForDuplication($squaread2);
			checkForDuplication($squaread3);
			checkForDuplication($squaread4);
			checkForDuplication($squaread5);
		});
		
		jQuery(".ctf-twitterlink").each(function() {
			var $this = jQuery(this);
			var href = $this.attr("href");
			href = href.replace(/\s+/g, "").replace(/\%20/g, "");
			$this.attr("href", href);
		});
		jQuery(".ctf-tweet-text a").each(function() {
			var $this = jQuery(this);
			var text = $this.text();
			if(text.indexOf("...") > -1) {
				text = $this.attr("title");
				$this.text(text);
			}
		});
		
		if(window.screen.width <= 800) {
			if(jQuery("#BBSISQContent04").length > 0 && jQuery("#BBSISQContent03").length > 0 && jQuery("#BBSIBNContent04").length > 0 && jQuery("#BBSISQContent01").length > 0) {
				jQuery("#BBSISQContent01").insertAfter(".featured_post").css("padding-top", "20px");
				jQuery("#Analysis").insertAfter("#BBSISQContent01");
				jQuery("#BBSISQContent04").insertAfter("#Analysis").css("padding-top", "20px");
				jQuery("#MostRead").insertAfter("#BBSISQContent04").css("padding-top", "20px");
				var $featuredvideo = jQuery("#MostRead").next().next();
				jQuery("#BBSISQContent03").insertAfter("#BBSISQContent04");
				var $latestnews = $featuredvideo.next().next();
				jQuery("#BBSIBNContent04").insertAfter($latestnews.find(".post-section:nth-child(5)")).css("padding-top", "20px");
				$latestnews.insertAfter($featuredvideo).css("padding-top", "20px");
				jQuery("#BBSILBContent01").insertAfter($latestnews).css("padding-top", "20px");
				jQuery("#Twitter").insertAfter("#BBSILBContent01").css("padding-top", "20px");
				jQuery("#Instagram").insertAfter("#Twitter").css("padding-top", "20px");
				jQuery("#newsletter").insertAfter("#Instagram").css("padding-top", "20px");
				jQuery("#DigitalEditions").insertAfter("#newsletter").css("padding-top", "20px");
				jQuery("#BBSIBNContent03").insertAfter("#MostRead").css("padding-top", "20px");
				
				setTimeout(function() {
					jQuery("#BBSISQContent04").insertAfter($featuredvideo);
				}, 1000);
				return;
			}
			if(jQuery("#BBSISQContent01").length > 0 && jQuery("#BBSISQContent03").length > 0 && $bannerad2.length > 0 && jQuery("#BBSISQContent04").length > 0) {
				var idx = 0;
				var childlen = jQuery(".entry-content").children().length;
				if(childlen > 9) {
					jQuery(".entry-content").children().each(function() {
						if(idx == 0) {
							jQuery("#BBSISQContent01").insertAfter(this).show();
						}
						
						if(idx == 3) {
							jQuery("#BBSISQContent03").insertAfter(this).show();
						}
						
						if(idx == 6) {
							$bannerad2.insertAfter(this).show();
						}
						
						if(idx == 9) {
							jQuery("#BBSISQContent04").insertAfter(this).show();
						}
						idx++;
					});
				}
				else if(childlen > 6)
				{
					jQuery(".entry-content").children().each(function() {
						if(idx == 0) {
							jQuery("#BBSISQContent01").insertAfter(this).show();
						}
						
						if(idx == 2) {
							jQuery("#BBSISQContent03").insertAfter(this).show();
						}
						
						if(idx == 4) {
							$bannerad2.insertAfter(this).show();
						}
						
						if(idx == 6) {
							jQuery("#BBSISQContent04").insertAfter(this).show();
						}
						idx++;
					});
				}
				else if(childlen > 3)
				{
					jQuery(".entry-content").children().each(function() {
						if(idx == 0) {
							jQuery("#BBSISQContent01").insertAfter(this).show();
						}
						
						if(idx == 1) {
							jQuery("#BBSISQContent03").insertAfter(this).show();
						}
						
						if(idx == 2) {
							$bannerad2.insertAfter(this).show();
						}
						
						if(idx == 3) {
							jQuery("#BBSISQContent04").insertAfter(this).show();
						}
						idx++;
					});
				}
				else {
					jQuery(".entry-content").children().each(function() {
						if(idx == 0) {
							jQuery("#BBSISQContent01").insertAfter(this).show();
							jQuery("#BBSISQContent03").insertAfter("#BBSISQContent03").show();
							$bannerad2.insertAfter("#BBSIBNContent02").show();
							jQuery("#BBSISQContent04").insertAfter("#BBSISQContent04").show();
						}
						idx++;
					});
				}
			}
		}
		if(isFindCompanies) setFindCompaniesBanners();
	}, 100);
	jQuery(".large-12 h2").each(function() {
		jQuery(this).addClass("widget-title");
	});
});
if(isKnowYourCommodity) setTimeout(setKnowYourCommodityBanners, 1);