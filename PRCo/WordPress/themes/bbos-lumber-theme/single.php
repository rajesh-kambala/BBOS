<?php
/**
 * The template for displaying all single posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
 *
 * @package Blue_Book_Services
 */
/*
$guid = GUID();
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPSQ" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPSQ2" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPSQ3" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPSQ4" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPSQ5" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPB" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="LumberMarketingSite" adtypes="PMSHPB2" maxcount="1" webuserid="0" industrytype="L" guid="'. $guid. '"]');
*/

get_header();
?>
	<div id="BBSIBNContent01" style="width: 100%; text-align: center; margin-top: 20px; height:0; visibility:hidden;"></div>
	<div id="BBSIBNContent02" style="width: 100%; text-align: center; margin-top: 20px; height:0; visibility:hidden;"></div>
	<div id="primary" class="content-area wrap">
		<div class="post_content_section">
			<div class="col_left sidebar desktop-sidebar">
				<?php
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['article-left-sidebar'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				// Article Left Sidebar
				reblex_display_block($sidebars[0]);
				?>
				<div id="BBSISQContent02" style="text-align: center; display: block !important;"></div>
				<div id="BBSISQContent04" style="text-align: center; display: block !important;"></div>
				<div id="BBSISQContent05" style="text-align: center; display: block !important;"></div>
			</div>
			<main id="main" class="site-main"><div class="col_center">
				<article>
		<?php
		while ( have_posts() ) :
				the_post();
				wpb_set_post_views(get_the_ID());
				echo '<div class="entry-header"><h1>'.get_the_title().'</h1></div>';
				echo '<div class="entry-sub-header"><h2>'. get_post_meta($post->ID, 'standfirst', true). '</h2></div>';
				$post = get_post();
				$ID = get_the_ID();
				$postdate = date_create($post->post_date);

					echo '<div class=:entry-meta"><span class="post-date">'. date_format($postdate,"F j, Y") .',</span>';
					$category_post = get_the_category($ID);
					if(count($category_post) > 0)
					{
						echo '<span class="published_category"> '. $category_post[0]->cat_name. '</span>';
					}
					$author = get_post_meta($ID, 'custom_author', true);
					if($author){
						echo '<span class="post-author">, '. $author .'</span>';
					}
					else {
						$author = get_post_meta($ID, 'author', true);
						if($author){
							echo '<span class="post-author">, '. $author .'</span>';
						}
					}
					echo '</div>';
					
					if ( has_post_thumbnail()) : 
						echo '<div style="text-align:center;padding-top:10px;">';
						//the_post_thumbnail();
						$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post->ID ));
						$imageID = get_post_thumbnail_id($post->ID);
						$imagealt = get_post_meta($imageID, '_wp_attachment_image_alt', true);
						$imagetitle = get_the_title( $imageID );
						if($imagealt == "") $imagealt = $imagetitle;
						
						echo '<img src="'. $featured_image_url. '" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" title="'. $imagetitle. '" alt="'. $imagealt. '" style="max-width:100%;">';
						echo '</div>';
					endif;
					
					echo '<div class="entry-content">';
					wpautop(the_content());
					echo '</div>';
				//part( 'template-parts/content', get_post_type() );

//	the_post_navigation();

			// If comments are open or we have at least one comment, load up the comment template.
			if ( comments_open() || get_comments_number() ) :
// 				comments_template();
			endif;

		endwhile; // End of the loop.
		?>
				<?php $pageLength = count($pages);
					  $url = $_SERVER['REQUEST_URI'];

					  $explodedURI = explode('/', $url);
					  end($explodedURI);
					  prev($explodedURI);
					  $keyTar = current($explodedURI);


					 if ($keyTar == $pageLength || $pageLength == '1') { ?>
				<?php
				$ID = get_the_ID();
				$aboutauthorarr = get_post_meta($ID, 'about-author');
				if(count($aboutauthorarr) > 0 && $aboutauthorarr[0]){ ?>
					 <p class="author-box">		
						<?php echo get_post_meta($ID,'about-author',true ); ?>
					</p>
				<?php } ?>
					 	
				<?php	 }

				?>
				<div class="entry-footer">
					<?php lumber_entry_footer(); ?>
					</div>
				</article>
				</div>
		</main><!-- #main -->
			<div class="col_right">
				
			<div class="sidebar mobile-sidebar">
				<?php 
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');	
				//} 
				?>
			</div>
			<div class="sidebar">
				<div id="BBSISQContent01" style="text-align: center; display: block !important;"></div>
			
				<?php 
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['article-right-sidebar'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Article Right Sidebar
				reblex_display_block($sidebars[0]);
				?>				
			</div>
			</div>
		</div>
	</div><!-- #primary -->


	<script type="text/javascript" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/jquery-1.7.2.min.js"></script>   
	<script type="text/javascript" id="bbsiGetAdsWidget" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/GetAdsWidget.min.js"></script>
    <script type="text/javascript">
		jQuery(function() {
			setTimeout(function() {
				var $bannerad1 = jQuery("#BBSIBNContent01");
				var $bannerad2 = jQuery("#BBSIBNContent02");
				var $squaread1 = jQuery("#BBSISQContent01");
				var $squaread2 = jQuery("#BBSISQContent02");
				var $squaread3 = jQuery("#BBSISQContent03");
				var $squaread4 = jQuery("#BBSISQContent04");
				var $squaread5 = jQuery("#BBSISQContent05");
				if(window.screen.width <= 800) {
					jQuery("article").css("margin-top", "0");
					var $paragraphs = jQuery(".entry-content > p, .entry-content > ul");
				
					if($paragraphs.length > 0) {
						$squaread1.insertAfter($paragraphs[0]);
					}
					else
					{
						$squaread1.appendTo(".entry-content");
						$bannerad1.insertAfter($squaread1);
						jQuery($squaread2).insertAfter($bannerad1);
						$squaread3.insertAfter($squaread2);
						$bannerad2.insertAfter($squaread3);
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 1) {
						$bannerad1.insertAfter($paragraphs[1]);
					}
					else
					{
						$bannerad1.insertAfter($squaread1);
						$squaread2.insertAfter($bannerad1);
						$squaread3.insertAfter($squaread2);
						$bannerad2.insertAfter($squaread3);
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 2) {
						$squaread2.insertAfter($paragraphs[2]);
					}
					else
					{
						$squaread2.insertAfter($bannerad1);
						$squaread3.insertAfter($squaread2);
						$bannerad2.insertAfter($squaread3);
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 3) {
						$squaread3.insertAfter($paragraphs[3]);
					}
					else
					{
						$squaread3.insertAfter($squaread2);
						$bannerad2.insertAfter($squaread3);
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 4) {
						$bannerad2.insertAfter($paragraphs[4]);
					}
					else
					{
						$bannerad2.insertAfter($squaread3);
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 5) {
						$squaread4.insertAfter($paragraphs[5]);
					}
					else
					{
						$squaread4.insertAfter($bannerad2);
						$squaread5.insertAfter($squaread4);
					}
				
					if($paragraphs.length > 6) {
						$squaread5.insertAfter($paragraphs[6]);
					}
					else
					{
						$squaread5.insertAfter($squaread4);
					}
				
					$sidebar = jQuery(".col_right .sidebar");
				
					if($sidebar.length > 1) {
						jQuery($sidebar[0]).appendTo($sidebar[1]);
					}
				}
				else {
					var $paragraphs = jQuery(".entry-content > p, .entry-content > ul");
					var jarticle = jQuery("article p:nth-child(2)");
					if($paragraphs.length > 1) {
						jarticle = jQuery($paragraphs[1]);
					}
					else if ($paragraphs.length == 1) {
						jarticle = jQuery($paragraphs[0]);
					}
					
					if (jarticle.hasClass("wp-caption-text")) {
						jarticle = jQuery("article p:nth-child(3)");
						if($paragraphs.length > 2) {
							jarticle = jQuery($paragraphs[2]);
						}
					}
					var jarticleimg = jarticle.find("img");
					var jarticle1 = jarticle.prev();
					var jarticle2 = jarticle.next();
					var jarticle3 = jarticle.next().next();
					var jarticle4 = jarticle3.next();
					var jarticle5 = jarticle4.next();

					if(jarticle.length == 1 && (jarticleimg.length == 0 || jarticle3.length == 0)) {
						$bannerad1.appendTo(jarticle);
						if(jarticle3.length == 0) {
							if(jarticle2.length == 0) {
								$bannerad2.appendTo($bannerad1);
							}
							else {
								$bannerad2.appendTo(jarticle2);
							}
						}
						else {
							$bannerad2.appendTo(jarticle3);
						}
					} else if(jarticleimg.length == 1 && jarticle3.length == 1) {
						 $bannerad1.appendTo(jarticle3);  
						 if(jarticle4.length == 0) {
							  $bannerad2.appendTo($bannerad1);
						 }
						 else if(jarticle5.length == 0) {
							  $bannerad2.appendTo(jarticle4);
						 }
						 else {
							  $bannerad2.appendTo(jarticle5);
						 }
					} else if(jarticle1.length == 1) {
						 $bannerad1.appendTo(jarticle1); 
						 if(jarticle3.length == 0) {
							  if(jarticle2.length == 0) {
								   $bannerad2.appendTo($bannerad1);
							  }
							  else {
								   $bannerad2.appendTo(jarticle2);
							  }
						 }
						 else {
							  $bannerad2.appendTo(jarticle3);
						 }
					} else {
						console.log("hiding");
						 $bannerad1.hide();
						 $bannerad2.hide();
					}
				}
				$bannerad1.css("visibility", "visible").css("height", "auto");
				$bannerad2.css("visibility", "visible").css("height", "auto");
			}, 100);
		});

        var licenseKey = "BBSIProduceAds";
        var pageName = "LumberMarketingSite";
        var ad1 = new BBSiGetAdsWidgetV2("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ", "L");
		var ad2 = new BBSiGetAdsWidgetV2("BBSISQContent02", licenseKey, pageName, 1, "PMSHPSQ2", "L");
		var ad3 = new BBSiGetAdsWidgetV2("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ3", "L");
		var ad5 = new BBSiGetAdsWidgetV2("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ4", "L");
		var ad6 = new BBSiGetAdsWidgetV2("BBSISQContent05", licenseKey, pageName, 1, "PMSHPSQ5", "L");
		var bad1 = new BBSiGetAdsWidgetV2("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB", "L");
		var bad2 = new BBSiGetAdsWidgetV2("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2", "L");
    </script>	
<?php
get_footer();
