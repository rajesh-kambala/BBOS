<!DOCTYPE html>

<!--[if lt IE 7 ]> <html class="ie ie6 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if IE 7 ]>    <html class="ie ie7 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if IE 8 ]>    <html class="ie ie8 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if lt IE 9]>
<script src="<?php bloginfo('template_directory'); ?>/_/js/ie9.min.js"></script><![endif]-->
<!--[if IE 9 ]>    <html class="ie ie9 no-js" <?php language_attributes(); ?>> <![endif]-->
<!--[if gt IE 9]><!--><html class="no-js" <?php language_attributes(); ?>><!--<![endif]-->
<!-- the "no-js" class is for Modernizr. -->

<head id="www-sitename-com" data-template-set="html5-reset-wordpress-theme" profile="http://gmpg.org/xfn/11" />
	<script>var page_title = "<?php echo get_the_title(); ?>"; var template_directory = "<?php bloginfo('template_directory'); ?>";</script>
	<meta charset="<?php bloginfo('charset'); ?>" />
	<?php if (is_search() || strrpos($_SERVER["REQUEST_URI"], "payment") || $_SERVER["QUERY_STRING"]) { ?>
	<meta name="robots" content="noindex, nofollow" /> 
	<?php } else { ?>
	<meta name="robots" content="max-image-preview:large, follow, index" />
	<?php } ?>
	
	<!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
	<meta name="robots" content="max-image-preview:large, follow, index" />
	<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/remodal.css" />
	<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/remodal-default-theme.css" />
	<link rel='stylesheet' id='load-fa-css'  href='https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css?ver=4.9.4' type='text/css' media='all' />
	<script type="text/javascript" id="bbsiGetAdsWidget" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/GetAdsWidget.min.js"; ?>"></script>
	<?php if (is_search()) { ?>
	<meta name="robots" content="noindex, nofollow" /> 
	<?php } else { ?>
	<meta name="robots" content="max-image-preview:large, follow, index" />
	<?php } ?>

	<title>
		   <?php
			  global $post;
			  $yoast_title = get_post_meta($post->ID, '_yoast_wpseo_title', true);
			  if($yoast_title != "") 
			  {
				echo $yoast_title;
			  }
			  else
			  {
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
				}
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

	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
	<link rel="shortcut icon" href="<?php bloginfo('template_directory'); ?>/imgs/BBSi_Seal_logo.ico">
	<link rel="apple-touch-icon" href="<?php bloginfo('template_directory'); ?>/imgs/apple-touch-icon.png">
	<link rel="stylesheet" href="<?php bloginfo('stylesheet_url'); ?>?v=1.0.1.8">
	<link rel="pingback" href="<?php bloginfo('pingback_url'); ?>" />
	
	<script type="text/javascript" src="<?php bloginfo('template_directory'); ?>/_/js/modernizr-2.6.2.min.js"></script> 

	<?php if ( is_singular() ) wp_enqueue_script( 'comment-reply' ); ?>

	<?php wp_head();
	
	if(isset($post) && $post != null && $post->ID == 691)
	{
		echo "<style>#post-691 {padding-top: 0; margin-top: -23px;}</style>";
	}
	?>
	<script src="<?php bloginfo('template_directory'); ?>/js/common.js?v=1.1" type="text/javascript"></script>
	
<!-- Google Tag Manager -->
<script>
(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','GTM-PK37TQK');
</script>
<!-- End Google Tag Manager -->
	<!--link rel='stylesheet' id='foundation-css-css'  href='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/css/foundation.min.css?ver=4.9.4' type='text/css' media='all' /-->
	<script type='text/javascript' src='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/foundation.min.js?ver=4.9.4'></script>
	<script type='text/javascript' src='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/plugins/foundation.util.motion.min.js?ver=4.9.4'></script>

</head>

<body <?php body_class(); ?>>
	<!-- Google Tag Manager (noscript) -->
	<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-PK37TQK"	height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
	<!-- End Google Tag Manager (noscript) -->


	<div class="remodal" data-remodal-id="modal">
	  <a data-remodal-action="close" class="remodal-close"></a>
		<div class="body"></div>
	  <a data-remodal-action="cancel" class="remodal-cancel" href="#">Cancel</a>
	  <a data-remodal-action="confirm" class="remodal-confirm" href="#">OK</a>
	</div>

		<header id="header">
			<div class="wrap">
				<div class="cell large-8 medium-8 small-5 column">
					<div class="mega_menu">
						<a href="#" class="mega_menu_toggler"><i class="fa fa-bars"></i></a>
							<div class="accordion-menu-section">
							<a href="#" class="mega_menu_toggler"><i class="fa fa-close"></i></a>
							<?php 
							wp_nav_menu(array(
								'menu' => 'main-nav',
								'theme_location' => 'mega-menu',
								'menu-id' => 'mega-menu'
							));
							?>
					</div>
				</div>
				<div class="left">
					<a href="/"><img src="<?php bloginfo('stylesheet_directory'); ?>/imgs/logo-BBS-lumber.png" /></a>
				</div>
				<div class="right">
					<span style="position: relative; top: 45px;"><?php 
					$args = [
						'post_type'      => 'wp_block',
						'posts_per_page' => 1,
						'post_name__in'  => ['header-buttons'],
						'fields'         => 'ids'
					];
					$sidebars = get_posts( $args );
					
					// Article Left Sidebar
					reblex_display_block($sidebars[0]);
					
					?></span>
					<span class="search_section" style="">
						<button class="button-link" id="toggle-search">
							<i class="fa fa-search"></i>
						</button>
						<form name="site-search" class="site-search" action="<?php echo get_site_url(); ?>" method="GET">
							<input type="text" name="s" placeholder="Enter keywords to search" />
		<!-- 					<input type="hidden" name="year" id="year_search"/>
							<input type="hidden" name="monthnum" id="month_search"/>
							<input type="hidden" name="day" id="day_search"/> -->
							<select name="date_range" id="search_date">
								<option value="0">Filter by Date</option>
								<option value="now">Today</option>
								<option value="-1 day">Yesterday</option>
								<option value="-1 week">This Week</option>
								<option value="-30 days">Last 30 Days</option>
								<option value="-90 days">Last 90 days</option>
							</select>
							<input type="hidden" name="order_by" value="date" />
							<input type="hidden" name="order" value="DSC" />
							<button type="submit" class="button button-icon-search"><i class="fa fa-search"></i></button>
							<button type="button" id="close-search">
								<i class="fa fa-close"></i>
							</button>
						</form>
					</span>
					<?php get_search_form(); ?>
				</div>
				<div class="clearfix"></div>
				<?php wp_nav_menu( array('menu' => 'main-nav', 'container_class' => 'nav' )); ?>
		</div><!--end wrap-->
		</header>

