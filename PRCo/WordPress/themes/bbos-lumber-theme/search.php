<?php
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);

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
if(isset($_GET['date_range']) && $_GET['date_range'] != "0"){
$date = date('Y-m-d', strtotime($_GET['date_range']));
$date_array = explode('-',$date);
$results = new WP_Query(
	array(
		'post_type' => array('post'),
		'posts_per_page'=> 10,
		's' => ((isset($_GET['s']) && $_GET['s'])? '"'.$_GET['s'].'"' : null),
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
	//print_r($results);
}else{
	$results = new WP_Query(
	array(
		'post_type' => array('post'),
		'posts_per_page'=> 10,
		's' => $_GET['s']?'"'.$_GET['s'].'"':null,
		'orderby' => 'date',
	'order' => 'DESC',
	'paged' =>  get_query_var('paged')  ? get_query_var('paged') : 1
	));
}
// print_r($_GET);
?>
<style>
h3 {
	line-height: 1em;
	padding-top: 10px;
}
h3 a {
	font-size: 0.75em;
	line-height: 1em;
	font-family: "Helvetica Neue",Helvetica,Roboto,Arial,sans-serif;
}
.entry-meta {
	margin-bottom: 10px;
}
.entry-footer {
	padding: 10px 25px;
}
#Grow_Sales_Lumber_LeaderboardAd, .comments-link {
	display:none;
}
</style>
	<div id="primary" class="content-area wrap">
		<div class="post_content_section">
			<div class="col_left sidebar desktop-sidebar">
				<?php 
				//if(is_active_sidebar('post_left_sidebar')){
					//dynamic_sidebar('post_left_sidebar');	
				//} 
				
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['most-read'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Article Left Side Bar
				reblex_display_block($sidebars[0]);
				
				?>
			</div>
			<main id="main" class="site-main"><div class="col_center">
				<article>
<?php				setup_postdata($results); ?>

		<?php if ( $results->have_posts() )  {  ?>
				
					<?php
					/* translators: %s: search query. */
					printf(__( '<h2>Search Results</h2><p>You searched for %s', 'blue-book-services' ), '<span>"' . get_search_query() . '" ' . $date_query . '</span>' );
					?>

			<?php
			/* Start the Loop */
			while ( $results->have_posts() ) :
				$results->the_post();

				/**
				 * Run the loop for the search to output the results.
				 * If you want to overload this in a child theme then include a file
				 * called content-search.php and that will be used instead.
				 */
				get_template_part( 'content', 'search' );

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

			get_template_part( 'content', 'none' );

		}
		?>
				<div class="entry-footer">
					<?php //lumber_entry_footer(); ?>
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
					<?php 
					//if(is_active_sidebar('post_right_sidebar')){
					//dynamic_sidebar('post_right_sidebar');	
				//} 
				
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['value-of-membership'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Article Left Side Bar
				reblex_display_block($sidebars[0]);
				
				?>
			</div>
			</div>
		</div>
	</div><!-- #primary -->	

		</main><!-- #main -->

			<!--div class="col_right">
				<div class="sidebar">
					
				<?php 
				if(is_active_sidebar('post_right_sidebar')){
					dynamic_sidebar('post_right_sidebar');	
				} ?>
			
				</div>
			</div-->
		</div>
	</section><!-- #primary -->

<?php
get_footer();
