<?php
/*
Template Name: Buy Membership Madison Page Template
*/
?>
<html>
<head id="www-sitename-com" data-template-set="html5-reset-wordpress-theme" profile="http://gmpg.org/xfn/11">

	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
	<link rel="stylesheet" media="screen"  href="/wp-content/themes/bbos-lumber-theme/remodal.css">
	<link rel="stylesheet" media="screen"  href="/wp-content/themes/bbos-lumber-theme/remodal-default-theme.css">
	
	<title>Buy Membership - Lumber Blue Book</title>
	<meta name="title" content="<?php the_title(); ?> - Lumber Blue Book">
	<meta name="description" content="">
	<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
	<link rel="shortcut icon" href="/wp-content/themes/bbos-lumber-theme/imgs/BBSi_Seal_logo.ico">
	<link rel="apple-touch-icon" href="/wp-content/themes/bbos-lumber-theme/imgs/apple-touch-icon.png">
	<link rel="stylesheet" href="/wp-content/themes/bbos-lumber-theme/style.css?ver=1.0">
	<link rel="pingback" href="/xmlrpc.php" />
	
	<script type="text/javascript" src="/wp-content/themes/bbos-lumber-theme/_/js/modernizr-2.6.2.min.js"></script> 

	
	<link rel='dns-prefetch' href='//ajax.googleapis.com' />
	<link rel='dns-prefetch' href='//maxcdn.bootstrapcdn.com' />
	<link rel='dns-prefetch' href='//s.w.org' />
	<link rel="alternate" type="application/rss+xml" title="Lumber Blue Book &raquo; Feed" href="/feed/" />
	<link rel="alternate" type="application/rss+xml" title="Lumber Blue Book &raquo; Comments Feed" href="/comments/feed/" />
	<link rel="alternate" type="application/rss+xml" title="Lumber Blue Book &raquo; Join Today Comments Feed" href="/join-today/feed/" />
	<link rel='stylesheet' id='jquery.prettyphoto-css'  href='/wp-content/plugins/wp-video-lightbox/css/prettyPhoto.css?ver=4.9.4' type='text/css' media='all' />
	<link rel='stylesheet' id='video-lightbox-css'  href='/wp-content/plugins/wp-video-lightbox/wp-video-lightbox.css?ver=4.9.4' type='text/css' media='all' />
	<link rel='stylesheet' id='sb_instagram_styles-css'  href='/wp-content/plugins/instagram-feed/css/sbi-styles.min.css?ver=2.8.2' type='text/css' media='all' />
	<link rel='stylesheet' id='contact-form-7-css'  href='/wp-content/plugins/contact-form-7/includes/css/styles.css?ver=5.0.1' type='text/css' media='all' />
	<link rel='stylesheet' id='ctf_styles-css'  href='/wp-content/plugins/custom-twitter-feeds-pro/css/ctf-styles.min.css?ver=1.14' type='text/css' media='all' />
	<link rel='stylesheet' id='wp-pagenavi-css'  href='/wp-content/plugins/wp-pagenavi/pagenavi-css.css?ver=2.70' type='text/css' media='all' />
	<link rel='stylesheet' id='load-fa-css'  href='https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css?ver=4.9.4' type='text/css' media='all' />
	<link rel='stylesheet' id='tablepress-default-css'  href='/wp-content/plugins/tablepress/css/default.min.css?ver=1.8' type='text/css' media='all' />
	<link rel='stylesheet' id='wp-my-instagram-css'  href='/wp-content/plugins/wp-my-instagram/css/style.css?ver=1.0' type='text/css' media='all' />
	<script type='text/javascript' src='//ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js?ver=4.9.4'></script>
	<script type='text/javascript' src='/wp-content/plugins/wp-video-lightbox/js/jquery.prettyPhoto.min.js?ver=3.1.6'></script>
	<script type='text/javascript' src='/wp-content/plugins/wp-video-lightbox/js/video-lightbox.js?ver=3.1.6'></script>
	<link rel='https://api.w.org/' href='/wp-json/' />
	<link rel="canonical" href="/join-today/" />
	<link rel='shortlink' href='/?p=390' />
	<link rel="alternate" type="application/json+oembed" href="/wp-json/oembed/1.0/embed?url=https%3A%2F%2Fwww.lumberbluebook.com%2Fjoin-today%2F" />
	<link rel="alternate" type="text/xml+oembed" href="/wp-json/oembed/1.0/embed?url=https%3A%2F%2Fwww.lumberbluebook.com%2Fjoin-today%2F&#038;format=xml" />
	<script src="<?php bloginfo('template_directory'); ?>/js/common.js?v=1.0" type="text/javascript"></script>
	<script>setButtonClick();</script>
	<!--link rel='stylesheet' id='foundation-css-css'  href='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/css/foundation.min.css?ver=4.9.4' type='text/css' media='all' /-->
	<script type='text/javascript' src='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/foundation.min.js?ver=4.9.4'></script>
	<script type='text/javascript' src='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/plugins/foundation.util.motion.min.js?ver=4.9.4'></script>

</head>

<body class="">

	<header id="header">
		<div class="wrap">
			<div class="left" style="width:50%;">
				<a href="https://madisonsreport.com" target="madison">
				<img style="width:85%; height:auto;" src="https://apps.bluebookservices.com/BBOS/images/MadisonLumberLogo.png"></a>
			</div>
			<div class="right" style="width:50%;">
				<a href="" target="bbsi">
				<img style="width:100%; height:auto;" src="/wp-content/themes/bbos-lumber-theme/imgs/logo-BBS-lumber.png"></a>
			</div>
			<div class="clearfix"></div>
		</div>
	</header>


<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		
		<article class="internal" id="post-<?php the_ID(); ?>">
			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
			<div class="entry">
				<?php the_content(); ?>

					<iframe id="MemberSelect" sandbox="allow-same-origin allow-top-navigation allow-forms allow-scripts allow-modals" 
					        height="2650px" width="1000px" seamless style="overflow: hidden;" scrolling="no" 
							src="https://<?php echo $_SERVER['SERVER_NAME']; ?>/LumberPublicProfiles/MembershipSelect.aspx?ML=Y">
					</iframe>  

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>


<footer id="footer" class="source-org vcard copyright wrap">
	<table style="width:90%;margin-left:auto;margin-right:auto;">
	<tr>
	<td style="text-align:center;width:33%">
		Contact <a href="https://madisonsreport.com/about/" target="madison">Madison's Lumber Reporter</a><br/>
		Keta Kosman, Editor<br/>
		604-319-2266
	</td>
	<td style="text-align:center;width:33%">
		Contact <a href="/contact-us/" target="bbsi">Lumber Blue Book</a><br/>
		Trent Johnson, Lumber Team Manager<br/>
		630-668-3500<br/>
	</td>
	<td style="text-align:center;width:33%">
		<a href="/terms-of-use/" target="bbsi">Terms of Use</a><br/>
		<a href="/privacy-policy/" target="bbsi">Privacy Policy</a><br/>
		&copy; Blue Book Services, LLC.
	</td>
	</tr>
	</table>
</footer>

</body>
</html>

