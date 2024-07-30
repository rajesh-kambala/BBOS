<?php
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);
/**
 * The header for our theme
 *
 * This is the template that displays all of the <head> section and everything up until <div id="content">
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package Blue_Book_Services
 */

?>
<!doctype html>
<html <?php language_attributes(); ?>>
<head>
	<script>var page_title = "<?php echo get_the_title(); ?>"; var template_directory = "<?php bloginfo('template_directory'); ?>";</script>
	<meta charset="<?php bloginfo( 'charset' ); ?>" />
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<?php if (is_search() || strrpos($_SERVER["REQUEST_URI"], "payment") || $_SERVER["QUERY_STRING"]) { ?>
	<meta name="robots" content="noindex, nofollow" /> 
	<?php } else { ?>
	<meta name="robots" content="max-image-preview:large, follow, index" />
	<?php } ?>
	<!--  Added by Patrick Johnson on 2/20/2019 in order to fix the display of the shortcut icon -->
	<link rel="shortcut icon" href="<?php bloginfo('template_directory'); ?>/imgs/BBSi_Seal_logo.ico" />
	<link rel="apple-touch-icon" href="<?php bloginfo('template_directory'); ?>/imgs/apple-touch-icon.png" />
	<link rel="profile" href="https://gmpg.org/xfn/11" />

	<?php wp_head(); ?>

	<!-- Google Tag Manager -->
	<script>
	(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src='https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);})(window,document,'script','dataLayer','GTM-W5PZ7DX');
	</script>
	<!-- End Google Tag Manager -->

	
	<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/remodal.css">
	<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/remodal-default-theme.css">
	<script src="<?php bloginfo('template_directory'); ?>/js/common.js?v=1.2" type="text/javascript"></script>
	<script>
<?php
/* REMOVED NEWSLETTER POPUP 3/30/2024 - PJOHNSON
if(!isset($_SERVER['HTTP_REFERER']) || !strrpos($_SERVER['HTTP_REFERER'], "news.bluebookservices.com"))
{
	global $post;
	$post_slug = (isset($post) && $post != null)? $post->post_name : "";
	
	if($post_slug != "know-your-produce-commodity-index")
	{
		if(isset($_REQUEST["setcookiefornewsletter"]))
		{
			setcookie("newslettersubscriber", "x", time() + (86400 * 30), "/", $_SERVER["SERVER_NAME"]);
		}
		else if(!isset($_COOKIE["newsletterpopup"]) && !isset($_COOKIE["setcookiefornewsletter"]) && $post != null && $post->ID != 7081 && $post->post_type != "kyc")
		{
			setcookie("newsletterpopup", "x", time() + (86400 * 30), "/", $_SERVER["SERVER_NAME"]);
			echo '
			onload = function() {setTimeout(showNewsletterPopup, 100);};';
		}
	}
}
*/
?>
	</script>
</head>
<body <?php body_class(); ?>>
<!-- Google Tag Manager (noscript) -->
<noscript><iframe src=https://www.googletagmanager.com/ns.html?id=GTM-W5PZ7DX height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->

<div id="page" class="site">
	<div class="remodal" data-remodal-id="modal">
	  <a data-remodal-action="close" class="remodal-close"></a>
	  <div class="body"></div>
	  <a data-remodal-action="cancel" class="remodal-cancel" href="#">Cancel</a>
	  <a data-remodal-action="confirm" class="remodal-confirm" href="#">OK</a>
	</div>
	<a class="skip-link screen-reader-text" href="#content"><?php esc_html_e( 'Skip to content', 'blue-book-services' ); ?></a>

	<header id="masthead" class="site-header grid-container">
		<div class="top-section grid-x">
		<div class="cell large-8 medium-8 small-5 column">
			<div class="mega_menu">
				<a href="#" class="mega_menu_toggler"><i class="fa fa-bars"></i></a>
					<div class="accordion-menu-section">
				<a href="#" class="mega_menu_toggler"><i class="fa fa-close"></i></a>
		
		<?php 
		wp_nav_menu(array(
			'theme_location' => 'mega-menu',
			'menu-id' => 'mega-menu'
		));
		?>
			</div>
		</div>
		<div class="site-branding" style="float:left;">
			<?php
			the_custom_logo();
		?>
		<!--div style="display:inline-block; font-family: 'Arial Black'; font-size: 52px; font-weight: bold;">Blue Book Services</div-->
		</div><!-- .site-branding -->
			<div class="search_section">
				<button class="button-link" id="toggle-search">
					<i class="fa fa-search" style="font-size: 36px;"></i>
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
					
			</div>

		</div>
			<div class="cell large-4 small-7 medium-4 column">
				<div class="top-section-links">
					<ul>
						<li><a class="button button-border-white" href="/media-kit">Advertise</a></li>
						<li><a class="button button-border-white" href="/bbos-login">Login</a></li>
						<li><a class="button button-border-white" href="/join-today">Join Today</a></li>
					</ul>
				</div>
			</div>
		</div>

		<nav id="site-navigation" class="main-navigation">
<!-- 			<button class="menu-toggle" aria-controls="primary-menu" aria-expanded="false"><?php esc_html_e( 'Menu ', 'blue-book-services' ); ?><i class="fa fa-bars"></i></button>	 -->
			<div class="site-branding-mobile">
			<?php
			the_custom_logo();
		?>
		<div style="display:inline-block; font-size: 28px; font-weight: bold;">Blue Book Services</div>
		</div><!-- .site-branding -->
			<?php
			wp_nav_menu( array(
				'theme_location' => 'menu-1',
				'menu_id'        => 'primary-menu',
			) );
			?>
		</nav><!-- #site-navigation -->
	</header><!-- #masthead -->

	<div id="content" class="site-content grid-container">
