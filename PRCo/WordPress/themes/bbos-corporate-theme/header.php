<!DOCTYPE html>

<!--[if lt IE 7 ]> <html class="ie ie6 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if IE 7 ]>    <html class="ie ie7 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if IE 8 ]>    <html class="ie ie8 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if lt IE 9]>
<script src="<?php bloginfo('template_directory'); ?>/_/js/ie9.min.js"></script><![endif]-->
<!--[if IE 9 ]>    <html class="ie ie9 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if gt IE 9]><!--><html class="no-js" <?php language_attributes(); ?>><!--<![endif]-->
<!-- the "no-js" class is for Modernizr. -->

<head id="www-sitename-com" data-template-set="html5-reset-wordpress-theme" profile="http://gmpg.org/xfn/11">
	<meta name="google-site-verification" content="9Q_7KFnBn746aq7yLfXrRiD9vhL_1876qlxzIyv09xw" />
	<meta charset="<?php bloginfo('charset'); ?>" />
	
	<!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<meta name="robots" content="max-image-preview:large, follow, index" />
	
	<?php if (is_search()) { ?>
	<meta name="robots" content="noindex, nofollow" /> 
	<?php } ?>

	<title>
		   <?php
			  $title = get_the_title();
		      if (function_exists('is_tag') && is_tag()) {
		         single_tag_title("Tag Archive for &quot;"); echo '&quot; - '; }
		      elseif (is_archive()) {
		         echo $title. ' Archive - '; }
		      elseif (is_search()) {
		         echo 'Search for &quot;'.esc_html($s).'&quot; - '; }
		      elseif (!(is_404()) && (is_single()) || (is_page())) {
		         if($title != "" && $title != "Home") echo $title. ' - '; 
			  }
		      elseif (is_404()) {
		         echo 'Not Found - '; }
		      if (is_home()) {
		         bloginfo('name'); echo ' - '; bloginfo('description'); }
		      else {
		          bloginfo('name'); }
		      if ($paged>1) {
		         echo ' - page '. $paged; }
		   ?>
	</title>
	
	<meta name="title" content="<?php
		      if (function_exists('is_tag') && is_tag()) {
		         single_tag_title("Tag Archive for &quot;"); echo '&quot; - '; }
		      elseif (is_archive()) {
		         echo $title. ' Archive - '; }
		      elseif (is_search()) {
		         echo 'Search for &quot;'.esc_html($s).'&quot; - '; }
		      elseif (!(is_404()) && (is_single()) || (is_page())) {
		         if($title != "" && $title != "Home") echo $title. ' - '; }
		      elseif (is_404()) {
		         echo 'Not Found - '; }
		      if (is_home()) {
		         bloginfo('name'); echo ' - '; bloginfo('description'); }
		      else {
		          bloginfo('name'); }
		      if ($paged>1) {
		         echo ' - page '. $paged; }
		   ?>">
	<meta name="description" content="<?php bloginfo('description'); ?>">
	
	<meta name="google-site-verification" content="">
	<!-- Speaking of Google, don't forget to set your site up: http://google.com/webmasters -->
	
	<meta name="author" content="Your Name Here">
	<meta name="Copyright" content="Copyright Your Name Here 2011. All Rights Reserved.">

	<!-- Dublin Core Metadata : http://dublincore.org/ -->
	<meta name="DC.title" content="Project Name">
	<meta name="DC.subject" content="What you're about.">
	<meta name="DC.creator" content="Who made this site.">
	
	<!--  Mobile Viewport meta tag
	j.mp/mobileviewport & davidbcalhoun.com/2010/viewport-metatag 
	device-width : Occupy full width of the screen in its current orientation
	initial-scale = 1.0 retains dimensions instead of zooming out if page height > device height
	maximum-scale = 1.0 retains dimensions instead of zooming in if page width < device width -->
	<!-- Uncomment to use; use thoughtfully!-->
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
	
	
	<link rel="shortcut icon" href="<?php bloginfo('template_directory'); ?>/imgs/BBSi_Seal_logo.ico">
	<!-- This is the traditional favicon.
		 - size: 16x16 or 32x32
		 - transparency is OK
		 - see wikipedia for info on browser support: http://mky.be/favicon/ -->
		 
	<link rel="apple-touch-icon" href="<?php bloginfo('template_directory'); ?>/imgs/apple-touch-icon.png">
	<!-- The is the icon for iOS's Web Clip.
		 - size: 57x57 for older iPhones, 72x72 for iPads, 114x114 for iPhone4's retina display (IMHO, just go ahead and use the biggest one)
		 - To prevent iOS from applying its styles to the icon name it thusly: apple-touch-icon-precomposed.png
		 - Transparency is not recommended (iOS will put a black BG behind the icon) -->
	
	<!-- CSS: screen, mobile & print are all in the same file -->
	<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>">
	<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />
	
	<!-- all our JS is at the bottom of the page, except for Modernizr. -->
	<script type='text/javascript' src='/wp-includes/js/jquery/jquery.min.js?ver=3.6.0' id='jquery-core-js'></script>
	<script src="<?php bloginfo('template_directory'); ?>/_/js/modernizr-2.6.2.min.js"></script> 
	
	<?php if ( is_singular() ) wp_enqueue_script( 'comment-reply' ); ?>

	<?php wp_head(); ?>
	
	<!-- Google tag (gtag.js) --> 
	<script async src=https://www.googletagmanager.com/gtag/js?id=G-SPXY250CKR></script> 
	<script> window.dataLayer = window.dataLayer || []; function gtag(){dataLayer.push(arguments);} gtag('js', new Date()); gtag('config', 'G-SPXY250CKR'); </script>	
	
	<!-- Google Analytics -->
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', 'UA-54784063-3', 'auto');
	  ga('send', 'pageview');

	</script>
	<!-- End Google Analytics -->
	
</head>

<body <?php body_class(); ?>>

		<header id="header">
			<div class="wrap">
				<div class="left">
					<img src="<?php bloginfo('stylesheet_directory'); ?>/imgs/logo-BBS.png" />
				</div>
				<div class="right memberloginright">
					<span class="btn-white"><a href="/bbos-Login/">Member Login</a></span>			
				</div>
				<div class="clearfix"></div>
				<?php wp_nav_menu( array('menu' => 'main-nav', 'container_class' => 'nav' )); ?>
		</div><!--end wrap-->
		</header>

