		<footer id="footer" class="source-org vcard copyright wrap">
			<div class="left">
			<?php wp_nav_menu( array('menu' => 'footer-nav' )); ?>
			</div>
			<div class="right login">
				<ul>
					<li><a href="/bbos-login/">Member Login</a></li>
					<li class="join"><a href="/join-today/">Join Today</a></li>
				</ul>
				<small>&copy;&nbsp;<?php echo date("Y"); ?> Blue Book Services</small>
				<!-- Social media icons -->
				<div width: 147px; style="margin-top: 7px;">
					<a href="https://www.youtube.com/BlueBookServices" target="_blank"><img src="/wp-content/uploads/2016/10/YouTube.png" alt="Lumber Blue Book Youtube" width="32px" height="32px" title="Lumber Blue Book Youtube"/></a>
					<a href="https://www.linkedin.com/showcase/lumber-blue-book" target="_blank"><img src="/wp-content/uploads/2015/10/Linkedin.png" alt="Lumber Blue Book LinkedIn" width="32px" height="32px" title="Lumber Blue Book LinkedIn" style="margin: 0px 13px 0px 0px";/></a>
				</div>
			</div>
			<div class="clearfix"></div>
		</footer>

	
	<?php wp_footer(); ?>

	<script type="text/javascript" src="<?php bloginfo('template_directory'); ?>/_/js/jquery.nivo.slider.pack.js"></script>
	<script type="text/javascript" src="<?php bloginfo('template_directory'); ?>/_/js/functions.js"></script>
	<script type="text/javascript" id="jQueryCookie" src="https://cdnjs.cloudflare.com/ajax/libs/jquery-cookie/1.4.1/jquery.cookie.min.js"></script>
<script>
		function showPopup(msg) {
			popped = 1;
			jQuery(".remodal .body").html(msg);
			//jQuery(".remodal .body").click(function (e) {
			//  e.preventDefault();
			//  e.stopPropagation();
			//});
			jQuery(".remodal-cancel, .remodal-confirm").hide();

			//if(typeof jQuery(jQuery(".remodal")[0]) == "undefined") {
			//	showPopup(msg);
			//	return;
			//}
			jQuery(jQuery(".remodal")[0]).remodal().open();
			return false;
		}

		var popped = 0;
		function hidePopup(t) {
			jQuery("#submitformframe").attr("src", "/?setcookiefornewsletter=1");
			if(jQuery(".remodal").length > 0) jQuery(jQuery(".remodal")[0]).remodal().close();
		}
		function showNewsletterPopup() {
			var $remodal = jQuery(".remodal");
			$remodal.css("width", "100%").css("max-width", "715px").css("min-height", "470px").css("background", "url(<?php bloginfo('template_directory'); ?>/imgs/popup_background.jpg?v=1.0)").css("background-size", "contain").css("background-repeat", "no-repeat");
			jQuery(".remodal-close").css("width", "100%").css("top", "15px");
			jQuery(".remodal-close").addClass("removeX");
			var top = 160;
			var right = 20;
			
			if(jQuery("html,body").width() < 500) {
				top = 70;
				right = 0;
			}
			showPopup('<iframe src="/" name="submitformframe" id="submitformframe" style="display:none;"></iframe><div id="popupDIV" style="margin:' + top + 'px auto; width:100%; max-width: 500px; font-size: 24px; color: #3E538C; background: white; padding-bottom: 20px;"><div id="popupstep1"><span style="color:#96C14E; font-weight:bold;">Receive the leading lumber e-newsletter</span> <span><em>featuring</em> breaking news, analysis and insights for <span style="color:#96C14E; font-weight:bold;">your success!</span><div style="color:#3E538C; position:relative; top: 10px; ">Sign Up For Free Here:</div><div style="margin-top:40px;"><button style="background: #3E538C; padding: 10px; color: white; margin-bottom:20px; margin-right: ' + right + 'px; font-size: 18px; width: 200px; cursor:pointer;" onclick="jQuery(\'#popupstep1\').hide();jQuery(\'#popupstep2\').show(); jQuery(\'#popupDIV\').css(\'position\', \'relative\').css(\'left\', \'-35px\'); jQuery(\'.remodal-close\').css(\'width\', \'93%\'); return false;">Yes, I Want It!</button><button style="background: #F2E9E2; padding: 10px; font-size: 18px; width: 200px; cursor:pointer;" onclick="hidePopup(); return false;">No, I Already Get It.</button></div></div><div id="popupstep2" style="display:none;"><form action="https://list.robly.com/subscribe/post" method="post" id="robly_embedded_subscribe_form_emailpopup" name="robly_embedded_subscribe_form" class="validate" target="_blank" novalidate="" onsubmit="return submitpopupform();"><input type="hidden" name="a" value="516720a7924648f6af19e38e04c1587d"><input type="hidden" name="sub_lists[]" value="340410"><h2 style="text-align:center;font-size: 1.2em;position:relative;left:-2px;">Sign Up for Free Here</h2><input type="email" value="" name="EMAIL" class="slim_email" id="emailpopupDATA0" placeholder="email address" required="" style="font-size: 0.7em;"><input type="submit" value="Subscribe" name="subscribe" class="slim_button" style="cursor:pointer; font-size: 0.7em;"></form></div></div>');
		}
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
			<?php
			echo  "console.log(document.cookie);";
			if(!isset($_SERVER['HTTP_REFERER']) || !strrpos($_SERVER['HTTP_REFERER'], "news.bluebookservices.com"))
			{
				echo '
				jQuery(function() {
					console.log(window.location.href.indexOf("setcookiefornewsletter"));
					if(window.location.href.indexOf("setcookiefornewsletter") > -1) {
						var date = new Date();
						date.setFullYear(date.getFullYear() + 1);
						console.log("setting newslettersubscriber");
						jQuery.cookie("newslettersubscriber", "x", { expires: date, path: "/" });
					}
					else if(!jQuery.cookie("newsletterpopup") && !jQuery.cookie("setcookiefornewsletter"))
					{
						var date = new Date();
						date.setFullYear(date.getFullYear() + 1);
						console.log("setting newsletterpopup");
						jQuery.cookie("newsletterpopup", "x", { expires: date, path: "/" });							
						setTimeout(showNewsletterPopup, 100);
					}
				});
				';
				/*
				if(isset($_REQUEST["setcookiefornewsletter"]))
				{
					setcookie("newslettersubscriber", "x", time() + (86400 * 30), "/", $_SERVER["SERVER_NAME"]);
				}
				else if(!isset($_COOKIE["newsletterpopup"]) && !isset($_COOKIE["setcookiefornewsletter"]) && $post != null && $post->post_type != "kyc")
				{
					setcookie("newsletterpopup", "x", time() + (86400 * 30), "/", $_SERVER["SERVER_NAME"]);
					echo '
					console.log(document.cookie);
					onload = function() {setTimeout(showNewsletterPopup, 100);};';
				}
				*/
			}
		?>	
});
var windowwidth = jQuery("html,body").width();
jQuery(".remodal-wrapper").width(windowwidth);
if(windowwidth <= 776) {
	jQuery(".site-search").width(windowwidth-60).css("left", (-1*(200-((600-windowwidth)/2))));
}
</script>
<script>
/*Newsletter js code start*/
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
  jQuery(function(){
	  if(jQuery("a[rel='wp-video-lightbox']").length > 0 && typeof jQuery("a[rel='wp-video-lightbox']").prettyPhoto != "undefined") {
		jQuery("a[rel='wp-video-lightbox']").prettyPhoto({animation_speed:'normal',theme:'light_square'});
	  }	  
  });
/*Newsletter js code end*/

</script>
<script src="<?php bloginfo('template_directory'); ?>/remodal.js" type="text/javascript"></script>
<style>
.remodal-close:before {
	font-size: 50px;
	position: relative;
	left: -20px;
	float: right;
	color: #666;
}
.items-module a { display:block; }
figcaption {
	font-size: 0.7em;
}
.aligncenter {
	margin: 0 auto;
}
</style>
</body>
</html>