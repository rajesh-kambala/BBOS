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
	's' => ((isset($_GET['s']) && $_GET['s'])?'"'.$_GET['s'].'"':null),
		'orderby' => 'date',
	'order' => 'DESC',
	'paged' =>  get_query_var('paged')  ? get_query_var('paged') : 1
));?>
	
	<section id="primary" class="wrap">
		<div class="more-news-section">
			
		<div class="col_left">
			<div class="desktop-sidebar">
				<div class="sidebar">
					
				<?php
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');
				//}
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
			</div>
		<main id="main" class="site-main more-news col_center">
			<div class="feed">

	<?php setup_postdata($results); ?>

		<?php if ( $results->have_posts() )  {  ?>

<!-- 			<header class="page-header"> -->
				
	      <?php
         		printf( '<h1 class="page-title text-center">More News</h1>' );
		?>
				
<!-- 			</header> -->
<!-- .page-header -->

			<?php
			/* Start the Loop */
			while ( $results->have_posts() ) :
				$results->the_post();
				$ID = get_the_ID();
	echo '<article class="post-section">';

				/**
				 * Run the loop for the search to output the results.
				 * If you want to overload this in a child theme then include a file
				 * called content-search.php and that will be used instead.
				 */
				$postdate = date_create($results->post->post_date);

				echo '<h3><a href="'.get_the_permalink().'">'.get_the_title().'</a></h3>';
				echo '<div class="entry-meta"><span class="post_date">'.date_format($postdate,"F j, Y").',</span>';
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
				echo '</article>';
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
			</div>
		</main><!-- #main -->
						<div class="right_col mobile-sidebar">
				<div class="sidebar">
					
				<?php
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');
				//}
				?>
				</div>
			</div>

			<div class="col_right">
				<div class="sidebar">
					
				<?php 
				//if(is_active_sidebar('post_right_sidebar')){
				//	dynamic_sidebar('post_right_sidebar');	
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
			
				</div>
			</div>
		</div>
			
	</section><!-- #primary -->

<?php
get_footer();
