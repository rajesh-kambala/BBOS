<?php
/**
 * The template for displaying search results pages
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#search-result
 *
 * @package Blue_Book_Services
 */

get_header();
//create a date array with year, month, and day
//echo get_query_var('paged')  ? get_query_var('paged') : 1;
$results = null;
function get_date_query(){
	if(isset($_GET['date_range']) && $_GET['date_range'] == "0"){
		return 'from all published articles';
	}
	else if(isset($_GET['date_range']) && $_GET['date_range'] == "now"){
		return 'from articles published today';
	}else if(isset($_GET['date_range']) && $_GET['date_range'] == "-1 day"){
		return 'from articles published yesterday';
	}else if(isset($_GET['date_range']) && $_GET['date_range'] == "-1 week"){
		return 'from articles published this week';
	}else if(isset($_GET['date_range']) && $_GET['date_range'] == "-30 days"){
		return 'from articles published in the last 30 days';
	}else if(isset($_GET['date_range']) && $_GET['date_range'] == "-90 days"){
		return 'from articles published in the last 90 days';
	}
}
$date_query = get_date_query();
if(isset($_GET['date_range']) && $_GET['date_range'] != "" && $_GET['date_range'] != "0"){
$date = date('Y-m-d', strtotime($_GET['date_range']));
$date_array = explode('-',$date);
$results = new WP_Query(
	array(
		'post_type' => array('post'),
		'posts_per_page'=> 10,
		's' => $_GET['s']?'"'.$_GET['s'].'"':null,
		'date_query' => array(
			'after'=> array(
			'year' => $date_array[0],
			'month' => $date_array[1],
			'day' => $date_array[2]
		),
			'inclusive' => true
		),
	'orderby' => 'date',
	'order' => 'DESC',
	'paged' =>  get_query_var('paged')  ? get_query_var('paged') : 1
		
	)
);
}else{
	$paged = ((get_query_var('paged') ) ? get_query_var('paged') : ((isset($_REQUEST["pg"]))  ? $_REQUEST["pg"] : 1));
	$results = new WP_Query(
	array(
		'post_type' => array('post'),
		'posts_per_page'=> 10,
		's' => $_GET['s']?'"'.$_GET['s'].'"':null,
		'orderby' => 'date',
	'order' => 'DESC',
	'paged' =>  $paged
	));
}
// print_r($_GET);
?>

	<section id="primary" class="content-area">
		<div class="grid-x">
			<div class="cell large-3 column desktop-sidebar">
				<div class="sidebar">
					
				<?php
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');
				//}

				// Article Left Sidebar
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['search-left-side-bar'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Article Left Side Bar
				reblex_display_block($sidebars[0]);
				?>
				</div>
			</div>
			
		<main id="main" class="site-main cell large-6 column">
	<?php				setup_postdata($results); ?>

		<?php if ( $results->have_posts() )  {  ?>

			<header class="page-header">
				
					<?php
					/* translators: %s: search query. */
					printf(__( '<h2 class="page-title">Search Results for:</h2> %s', 'blue-book-services' ), '<span>"' . get_search_query() . '" ' . $date_query . '</span>' );
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
				global $paged;
				$nextpage = 1;
				$max_page = ceil($results->found_posts/10);
 
				if ( !is_single() ) {
					if ( !$paged ) {
						$paged = 1;
					}
					$nextpage = intval( $paged ) + 1;
					$prevpage = intval( $paged ) - 1;
				}
				//echo next_posts_link('Older Posts', ceil($results->found_posts/10));
				if($nextpage < $max_page)
				{
					echo '<a href="/?s='. $_GET['s']. '&date_range='. $_GET['date_range']. '&pg='. $nextpage. '">Older Posts</a>';
				}
				if($prevpage > 0)
				{
					echo '<a href="/?s='. $_GET['s']. '&date_range='. $_GET['date_range']. '&pg='. $prevpage. '">Newer Posts</a>';
				}
				//echo previous_posts_link('Newer Posts');
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
				//if(is_active_sidebar('post_right_sidebar')){
				//	dynamic_sidebar('post_right_sidebar');	
				//}

					// Article Right Sidebar
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
	</section><!-- #primary -->
    <script defer="defer" type="text/javascript">
	jQuery(function() {
        var licenseKey = "BBSIProduceAds";
        var pageName = "ProduceMarketingSite";

        var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
        var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
		var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "IA,IA_180x90,IA_180x570");
        var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
        var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
        var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
        var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
		var ad8 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90");
		var ad9 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
		jQuery(".sidebar").show();
	});
    </script>
<style>
#BBSIOAContent02 {
	margin-top:100px;
}
.sidebar {
	display:none;
}
</style>	
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
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="3" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="4" webuserid="0" industrytype="P" guid="'. $guid. '"]');
*/
