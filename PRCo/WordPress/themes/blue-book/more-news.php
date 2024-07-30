<?php
/**
 * Template Name: More News Page Template
 *
 * @package Blue_Book_Services
 */

get_header();
$results = null;
// EDITED BY PJOHNSON ON 2/19/2019 AS IT APPEARED TO BE EXPECTED THAT ONLY POSTS SHOULD SHOW UP HERE
$results = new WP_Query(
	array(
		//'post_type' => array('post', 'page'),
		'post_type' => array('post'),
		'posts_per_page'=> 10,
	's' => (isset($_GET['s']) && $_GET['s'])?'"'.$_GET['s'].'"':null,
		'orderby' => 'date',
	'order' => 'DESC',
	'paged' =>  get_query_var('paged')  ? get_query_var('paged') : 1
));?>

	<section id="primary" class="content-area">
		<div class="grid-x">
			<div class="cell large-3 column desktop-sidebar">
				<div class="sidebar">
					
				<?php
				$leftsidebar_post = get_field('left_sidebar');
				$rightsidebar_post = get_field('right_sidebar');
				$content = $leftsidebar_post->post_content;
				$blocks = parse_blocks( $content );
				  foreach( $blocks as $block ) {
					//if( 'core/quote' === $block['blockName'] ) {
					  echo do_shortcode(render_block( $block ));
					  //break;
					//}
				  }
				?>
				</div>
			</div>
			
		<main id="main" class="site-main more-news cell large-6 column">

	<?php setup_postdata($results); ?>

		<?php if ( $results->have_posts() )  {  ?>

			<header class="page-header">
				
	      <?php
         		printf( '<h1 class="page-title">More Produce Industry News</h1>' );
		?>
				
			</header><!-- .page-header -->

			<?php
			/* Start the Loop */
			while ( $results->have_posts() ) :
				$results->the_post();

				/**
				 * Run the loop for the search to output the results.
				 * If you want to overload this in a child theme then include a file
				 * called content-search.php and that will be used instead.
				 */
				get_template_part( 'template-parts/content', 'search' );

			endwhile;
 			$current_page = get_query_var('paged')?get_query_var('paged'):1;
 		//	if($results->found_posts && $results->found_posts > 10){
		$next_page_have_posts = $results->found_posts / $current_page;
			
 		//	if($next_page_have_posts > 0){
				echo '<div class="post-nav">';
				echo next_posts_link('Older Posts', ceil($results->found_posts/10));
				echo previous_posts_link('Newer Posts');
				echo '</div>';
 		//	}

 		//	}
}
		else {

			get_template_part( 'template-parts/content', 'none' );

		}
		?>

		</main><!-- #main -->
						<div class="cell large-3 column mobile-sidebar">
				<div class="sidebar">
					
				<?php
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');
				//}
				?>
				</div>
			</div>

			<div class="cell large-3 column">
				<div class="sidebar">
					
				<?php 
				$content = $rightsidebar_post->post_content;
				$blocks = parse_blocks( $content );
				  foreach( $blocks as $block ) {
					//if( 'core/quote' === $block['blockName'] ) {
					  echo do_shortcode(render_block( $block ));
					  //break;
					//}
				  }
				?>
			
				</div>
			</div>
		</div>
	</section><!-- #primary -->
    <script defer="defer" type="text/javascript">
	jQuery(function() {
		var $ = jQuery;
        var licenseKey = "BBSIProduceAds";
        var pageName = "ProduceMarketingSite";

        var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
        var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
		var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "IA,IA_180x90,IA_180x570");
        var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
        var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
        var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
        var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
		jQuery(function() {
			jQuery("<div id=\"BBSIBNContent01\" style=\"position: relative;\"></div>").insertBefore("#main header");
			jQuery("<div id=\"BBSIBNContent03\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter("#main article:nth-child(4)");
			jQuery("<div id=\"BBSIBNContent04\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter("#main article:nth-child(8)");
			if(window.screen.width <= 800) {
				jQuery("#BBSISQContent01").insertAfter(jQuery("#main article")[0]);
				jQuery("#BBSISQContent03").insertAfter(jQuery("#main article")[1]);
				jQuery("#BBSIBNContent03").insertAfter(jQuery("#main article")[2]);
				jQuery("#BBSISQContent04").insertAfter(jQuery("#main article")[3]);
			}
		});
	});
    </script>	
<?php
get_footer();
/*
$guid = GUID();
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPSQ" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPB" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90,IA_180x570" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPSQ2" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPSQ3" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPB2" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPB3" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
*/
