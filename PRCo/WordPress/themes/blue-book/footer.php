<?php
/**
 * The template for displaying the footer
 *
 * Contains the closing of the #content div and all content after.
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package Blue_Book_Services
 */
?>

	</div><!-- #content -->

	<footer id="colophon" class="site-footer">
		<div class="container">
			<div class="small-2 contact-us" style="width: 26%;">
				<h6 style="margin: 20px; margin-left:0;">Contact Us</h6>
				<div>845 E. Geneva Rd. Carol Stream, IL, 60188</div>
				<div style="margin-bottom: 20px;">Phone: 630 668-3500</div>
				<div>E-Mail: <a href="mailto:info@bluebookservices.com">info@bluebookservices.com</a></div>
				<div>Press Releases: <a href="mailto:news@bluebookservices.com">news@bluebookservices.com</a></div>
				<div class="footer-links grid-container" style="height: 50px;">
					<!--?php
					wp_nav_menu(array(
						'theme_location' => 'footer-menu',
						'menu_id' => 'footer-links',
					)); 
					?-->
				</div>

				<div class="social-links grid-container">
					<?php
					wp_nav_menu(array(
						'theme_location' => 'social-menu',
						'menu_id' => 'social-links',
					)); 
					?>
				</div>
				<!--
				<div class="site-info">
					<a href="<?php echo esc_url( __( 'https://wordpress.org/', 'blue-book-services' ) ); ?>">
						<?php
						/* translators: %s: CMS name, i.e. WordPress. */
						printf( esc_html__( 'Proudly powered by %s', 'blue-book-services' ), 'WordPress' );
						?>
					</a>
				</div>
				-->
			</div>
			<div class="small-4">
				<h6 style="margin: 20px;">Recent Posts</h6>
				<ul id="slider-id" class="slider-class">
					<?php
					$recent_posts = wp_get_recent_posts(array(
						'numberposts' => 4, // Number of recent posts thumbnails to display
						'post_status' => 'publish' // Show only the published posts
					));
					foreach( $recent_posts as $post_item ) : ?>
						<li>
							<a href="<?php echo get_permalink($post_item['ID']) ?>">
								<table>
								<tr>
								<td>
								<?php 
								//echo get_the_post_thumbnail($post_item['ID'], 'full'); 
								$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post_item['ID'] ));
								$imageID = get_post_thumbnail_id($post_item['ID']);
								$imagealt = get_post_meta($imageID, '_wp_attachment_image_alt', true);
								$imagetitle = get_the_title( $imageID );
								if($imagealt == "") $imagealt = $imagetitle;
		
								if($featured_image_url) echo '<img src="'. $featured_image_url. '" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" title="'. $imagetitle. '" alt="'. $imagealt. '" style="max-width:100%;">';
								?>
								</td>
								<td>
								<p class="slider-caption-class"><?php echo $post_item['post_title']; ?><div class="date"><?php echo date('M d, Y',strtotime($post_item['post_date'])); ?></div></p>
								</td>
								</tr>
								</table>
							</a>
						</li>
					<?php endforeach; ?>
				</ul>
			</div>
			<div class="small-2" style="text-align: center; margin-left: 10px; position: relative; top: 20px;">
				<div class="produce_reporter"><img style="max-width: 175px; margin-bottom: 20px;" src="<?php bloginfo('stylesheet_directory'); ?>/imgs/PR_stack-white.png" /></div>
				<h3>Daily eNews Sign Up Here</h3>
				<form action="https://list.robly.com/subscribe/post" method="post" id="robly_embedded_subscribe_form" name="robly_embedded_subscribe_form" class="validate" target="_blank" novalidate="">
					<input type="hidden" name="a" value="516720a7924648f6af19e38e04c1587d" />
					<input type="hidden" name="sub_lists[]" value="329573" />
					<div class="emaildiv" style="width:260px; margin:0 auto; text-align: center; position: relative; left: 100px;">
						<input type="email" value="" name="EMAIL" class="slim_email" id="DATA0" placeholder="Enter your email" required="" style="display:none;" />
						<input type="image" src="/wp-content/uploads/sites/4/2021/04/arrow-alt-circle-right-regular-blue.jpg" value="" name="subscribe" class="slim_button g-recaptcha" style="color:transparent; background: none !important; cursor:pointer;" />
					</div>
				  </form>
			</div>
		</div>
		<div class="bottom">
			<div class="container bottom">
				<div class="site-info">&copy;&nbsp;<?php echo date("Y"); ?> Blue Book Services</div>
				<div class="footer-links grid-container">
					<div class="menu-footer-menu-container">
						<ul id="footer-links" class="menu">
							<li id="menu-item-767" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-767"><a href="/about-us/">About Us</a></li>
							<li id="menu-item-577" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-577"><a href="/industry-links/registered-developer-links/">Registered Developers</a></li>
							<li id="menu-item-773" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-773"><a href="/find-companies/company-directory/">Companies</a></li>
							<li id="menu-item-8182" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-8182"><a href="/about-us/video-library/">Testimonials</a></li>
							<li id="menu-item-926" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-926"><a href="/espanol/">Español</a></li>
							<li id="menu-item-576" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-576"><a href="/terms-of-use/">Terms of Use</a></li>
							<li id="menu-item-575" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-575"><a href="/privacy-policy/">Privacy Policy</a></li>
							<li id="menu-item-394712" class="menu-item menu-item-type-post_type menu-item-object-page menu-item-394712"><a href="/community-standards/">Community Standards</a></li>
							<li id="menu-item-774" class="menu-item menu-item-type-custom menu-item-object-custom menu-item-774"><a href="https://www.bluebookservices.com/">Corporate</a></li>
						</ul>
					</div>
				</div>
			</div>
		</div>
	</footer><!-- #colophon -->
</div><!-- #page -->
<?php
global $post;
	if($post != null && $post->post_type != "kyc")
	{
		echo '<script type="text/javascript" id="bbsiGetAdsWidget" src="'. BBSI_APPS. '/BBOSWidgets/javascript/GetAdsWidget.min.js"></script>';
	}
	
echo "<script>var isFindCompanies = false;var isKnowYourCommodity = false;";
$post_slug = (isset($post) && $post != null)? $post->post_name : "";
if($post_slug == "find-companies" || $post_slug == "find-produce-companies") echo "isFindCompanies = true;";
if($post_slug == "know-your-produce-commodity-index") echo "isKnowYourCommodity = true;";
echo "</script>";
?>
<script src="<?php bloginfo('template_directory'); ?>/js/footer.js?v=1.22" type="text/javascript"></script>
<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/css/footer.css?v=1.0">
<?php 
	wp_footer();
//Added by Mobiloud for fixing inner article links- Please don't remove.
if($post != null && $post->ID == 7081) : 
	if ( isset( $_SERVER['HTTP_X_ML_PLATFORM'] ) && ( $_SERVER['HTTP_X_ML_PLATFORM'] === "iOS" || $_SERVER['HTTP_X_ML_PLATFORM'] === "Android" ) || strlen( strstr( $_SERVER['HTTP_USER_AGENT'], "Mobiloud" ) ) > 0 ) {
		echo '<script type="text/javascript">   
		
		jQuery( document ).ready(function() {
			const article=document.getElementsByTagName("article")[0];	
		
			 jQuery("body .entry-content a").each(function()
			 {				
				 var $this = jQuery(this);
				 var $href=$this.attr("href");
				 var $target=$this.attr("target");
					 if($target=="_blank")
					 {
						 $this.attr("onclick", "nativeFunctions.handleLink( \'"+ $href +"\', \'External\', \'internal\')");
						 $this.removeAttr("href");
						 $this.removeAttr("target");
					 }
				 }).delay( 3000 ); 

				 jQuery( "body #kycd1, body #kycd2, body #kycd3, body #kycAds .item" ).on( "click", "a", function(e) {					
					e.preventDefault();					
					var $this = jQuery(this);
				 var $href=$this.attr("href");
				 var $target=$this.attr("target");
				 if($target=="_blank")
				 {
					console.log("Href:"+$href);
					nativeFunctions.handleLink( \'"+ $href +"\', \'External\', \'internal\');
				 }
				 				    
				  });
				
		  });
		</script>';
		}
endif;


?>
<!--<p>Footer</p>-->
<link rel="preconnect" href="https://fonts.gstatic.com" />
<link href="https://fonts.googleapis.com/css2?family=Roboto+Slab&display=swap" rel="stylesheet" />
<link href="https://fonts.googleapis.com/css2?family=Montserrat&display=swap" rel="stylesheet" />
<script src="<?php bloginfo('template_directory'); ?>/remodal.js" type="text/javascript"></script>
</body>
</html>
