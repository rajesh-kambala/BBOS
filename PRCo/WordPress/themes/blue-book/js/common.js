// Google Tag Manager
(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
})(window,document,'script','dataLayer','GTM-W5PZ7DX');

//Google Analytics
(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','//www.google-analytics.com/analytics.js','ga');

ga('create', 'UA-54784063-1', 'auto');
ga('send', 'pageview');

// checks for a valid email address
function isEmail(e)
{
	if (!e)
	{
		return false;
	}
	var matchArray = e.match(/^(\".*\"|\w(\w|\.|-)*\w)@(\[\d{1,3}(\.\d{1,3}){3}]|\w(\w|-)*\.(\w|\.|-)*\w)$/);
	if (matchArray == null)
	{
		return false;
	}
	// make sure the IP address domain is valid
	var IPArray = matchArray[2].match(/^[(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})]$/);
	if (IPArray != null)
	{
		var jj;
		for (jj = 1; jj <= 4; jj++)
		{
		  if (IPArray[jj] > 255)
		  {
			return false;
		  }
		}
	}
	return true;
}
function submitpopupform()
{
	var email = jQuery("#emailpopupDATA0").val();
	if(!isEmail(email)) {
		alert("Please enter a valid email.");
		return false;
	}
	else {
		hidePopup();
		return true;
	}
	return true;
}
function setCookie (name, value) {
		var d = new Date();
		d.setTime(d.getTime() + (365*24*60*60*1000));
		var expires = "expires="+ d.toUTCString();
		document.cookie = name + "=" + value + "; " + expires + "; path=/";
}
function showPopup(msg) {
	popped = 1;
	jQuery(".remodal .body").html(msg);
	jQuery(".remodal-cancel, .remodal-confirm").hide();
	jQuery(jQuery(".remodal")[0]).remodal().open();
	return false;
}

var popped = 0;
function hidePopup(t) {
	jQuery("#submitformframe").attr("src", "/?setcookiefornewsletter=1");
	if(jQuery(".remodal").length > 0) jQuery(jQuery(".remodal")[0]).remodal().close();
}
function showNewsletterPopup() {
	if(document.cookie.indexOf("newsletterpopup=x") > -1 || document.cookie.indexOf("setcookiefornewsletter=x") > -1 || document.location.href.indexOf("know-your-produce-commodity-index") > -1) return;
	var $remodal = jQuery(".remodal");
	$remodal.css("width", "100%").css("max-width", "715px").css("min-height", "470px").css("background", "url(" + template_directory + "/imgs/popup_background.jpg)").css("background-size", "contain").css("background-repeat", "no-repeat");
	jQuery(".remodal-close").css("width", "100%").css("top", "15px");
	jQuery(".remodal-close").addClass("removeX");
	var top = 160;
	var right = 20;
	
	if(jQuery("html,body").width() < 500) {
		top = 70;
		right = 0;
	}
	showPopup('<iframe src="/" name="submitformframe" id="submitformframe" style="display:none;"></iframe><div id="popupDIV" style="margin:' + top + 'px auto; width:100%; max-width: 500px; font-size: 24px; color: #3E538C; background: white; padding-bottom: 40px;"><div id="popupstep1"><span style="color:#96C14E; font-weight:bold;">Receive the <em>leading,</em> daily produce e-newsletter</span> <span><em>featuring</em> breaking news, analysis, retail and food service insights for <span style="color:#96C14E; font-weight:bold;">your Success!</span><div style="margin-top:40px;"><button style="background: #3E538C; padding: 10px; color: white; margin-bottom:20px; margin-right: ' + right + 'px; font-size: 18px; width: 200px; cursor:pointer;" onclick="jQuery(\'#popupstep1\').hide();jQuery(\'#popupstep2\').show(); return false;">Yes, I Want It!</button><button style="background: #F2E9E2; padding: 10px; font-size: 18px; width: 200px; cursor:pointer;" onclick="hidePopup(); return false;">No, I Already Get It.</button></div></div><div id="popupstep2" style="display:none;"><form action="https://list.robly.com/subscribe/post" method="post" id="robly_embedded_subscribe_form_emailpopup" name="robly_embedded_subscribe_form" class="validate" target="_blank" novalidate=""><input type="hidden" name="a" value="516720a7924648f6af19e38e04c1587d"><input type="hidden" name="sub_lists[]" value="329573"><h2>Daily eNews Sign Up Here</h2><input type="email" value="" name="EMAIL" class="slim_email" id="emailpopupDATA0" placeholder="email address" required="" style="display:none;"><input type="submit" value="Subscribe" name="subscribe" class="slim_button" style="cursor:pointer;"></form></div></div>');
}
function getFrame(win, name) {
	var frameDom = null;
	var fram = null;

	if (typeof name == "object") {
		if (name.length) {
			frameDom = name[0];
		}
		else {
			frameDom = name;
		}
	}
	else {
		if (win == null || win.frames[name] == null || typeof win.frames[name] == "undefined") return null;
		frameDom = win.frames[name];
	}
	fram = (frameDom.contentWindow || frameDom.contentDocument);
	if (typeof fram == "undefined") fram = win.frames[name];
	if (fram != null) {
		if (fram.defaultView) fram = win.defaultView;
	}

	return fram;
}
function setScroll() {
	jQuery(window).scrollTop(0);
}
function setButtonClick() {
	var $button = null;
	try {
		var win = getFrame(window, "MemberSelect");
		if(!win || win == null || typeof win.jQuery != "function" || win.jQuery(".button").length == 0) {
			setTimeout(setButtonClick, 100);
			return;
		}
		setTimeout(setScroll, 1000);
		win.jQuery(".button").each(function(){
			var $this = win.jQuery(this);
			if($this.text() == "Next") {
				$button = $this;
				return
			}
		});
		if($button != null) {
			$button.click(function(){
				setTimeout(setButtonClick, 100);
			});
		}
	}
	catch(ex){}
}
var $ = jQuery;