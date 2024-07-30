<?php
/**
Front Page Template
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

<style>
.nivoSlider { position: relative; width: 932px; overflow: hidden; }
</style>

<div class="front_page">

	<div class="wrap">
		<div id="nivo">
			<div class="slider-wrapper theme-default">
            	<div id="slider" class="nivoSlider">
				<?php 
					//$content = get_post('1921');
					//echo $content->post_content;
				
					$args = [
						'post_type'      => 'wp_block',
						'posts_per_page' => 1,
						'post_name__in'  => ['home-page-slides'],
						'fields'         => 'ids'
					];
					$sidebars = get_posts( $args );
					
					// Home Page Slides
					reblex_display_block($sidebars[0]);

					// Article Left Side Bar
					$leftsidebar_post = get_field('left_sidebar');
					$rightsidebar_post = get_field('right_sidebar');
				?>
				</div>
			</div>
		</div>
	<div class="fp_left_col">
		<?php 
		$content = $leftsidebar_post->post_content;
		$blocks = parse_blocks( $content );
		  foreach( $blocks as $block ) {
			//if( 'core/quote' === $block['blockName'] ) {
			  echo do_shortcode(render_block( $block ));
			  //break;
			//}
		  }
		//if(is_active_sidebar('hp_left_sidebar')){
		//	dynamic_sidebar('hp_left_sidebar');
		//}
		?>
		<div id="BBSISQContent02" style="text-align: center; display: block !important;"></div>
		<div id="BBSISQContent04" style="text-align: center; display: block !important;"></div>
		<div id="BBSISQContent05" style="text-align: center; display: block !important;"></div>
	</div>
	<div class="fp_center_col">
		<div class="cell large-7 feed">
			<div class="cell large-12">
				<h2 class="text-center">
					Latest Industry News
				</h2>
			</div>
			<?php
			    $postCount = 0;
			
				$category_posts = new WP_Query(array(
					'post_type' => array('post'),
					'posts_per_page' => 10,
					'orderby' => 'date',
					'order' => 'DESC',
					'category__not_in' => array(4, 'Featured')
				));
				
				if($category_posts->have_posts()){
					while($category_posts->have_posts()){
						
						$category_posts->the_post();
						$ID = get_the_ID();
						echo '<div class="cell large-12 post-section">';
						$category_post = get_the_category($ID);
						echo '<h3><a href="'.get_post_permalink().'">'.get_the_title().'</a></h3>';
						echo '<div class="entry-meta">';
						$postdate = date_create($category_posts->post->post_date);

						echo '<span class="published_date">'.date_format($postdate,"F j, Y").',</span>';
						//echo '<span class="published_category">'. ((count($category_post) > 0)? $category_post[0] : "").'</span>';
						if(count($category_post) > 0)
						{
							echo '<span class="published_category"> '. $category_post[0]->cat_name. '</span>';
						}
						$author = get_post_meta($ID, 'custom_author', true);
						if($author){
							echo '<span class="post-author">, '. $author .'</span>';
						}
						echo '</div><!-- .entry-meta -->';
						echo '</div>';
						
						$postCount++;
						if($postCount == 2) {
							echo '<div id="BBSIBNContent01" style="text-align: center; display: block !important;margin-top:10px;"></div>';	
						}
						if($postCount == 5) {
							echo '<div id="BBSIBNContent02" style="text-align: center; display: block !important;margin-top:10px;"></div>';	
						}
					}
					echo '<a class="button button-primary" href="/more-news/page/2">More News</a>';
				}				
			?>
		</div>
	</div>
	<div class="fp_right_col">
	
		<div id="BBSISQContent01" style="text-align: center; display: block !important;"></div>
	
		<?php 
		//if(is_active_sidebar('hp-right-sidebar')){
		//	dynamic_sidebar('hp-right-sidebar');
		//}
		$content = $rightsidebar_post->post_content;
		$blocks = parse_blocks( $content );
		  foreach( $blocks as $block ) {
			//if( 'core/quote' === $block['blockName'] ) {
			  echo do_shortcode(render_block( $block ));
			  //break;
			//}
		  }
		?>
		
		<div id="BBSISQContent03" style="text-align: center; display: block !important;"></div>
	</div>
</div>
</div>
	<script type="text/javascript" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/jquery-1.7.2.min.js"></script>   
    <script type="text/javascript">		
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
				if(window.screen.width <= 800) {
					var $industrydivs = jQuery(".fp_center_col > div .large-12");
				
					if($industrydivs.length > 2) {
						$squaread1.insertAfter($industrydivs[2]);
					}
				
					if($industrydivs.length > 4) {
						$bannerad1.insertAfter($industrydivs[4]);
					}
				
					if($industrydivs.length > 6) {
						$squaread2.insertAfter($industrydivs[6]);
						$squaread3.insertAfter("#BBSISQContent02");
					}
				
					if($industrydivs.length > 8) {
						$bannerad2.insertAfter($industrydivs[8]);
					}

					$squaread4.appendTo(".fp_center_col > div");
					$squaread4.css("margin-top", "20px");
					$squaread5.insertAfter("#BBSISQContent04");	
					$squaread5.css("margin-top", "10px");
				}
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
