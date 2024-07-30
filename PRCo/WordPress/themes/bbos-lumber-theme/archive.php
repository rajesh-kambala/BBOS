<?php
/**
 * Template Name: More News Page Template
 *
 * @package Blue_Book_Services
 */

get_header();
?>	
	<section id="primary" class="wrap">
		<div class="more-news-section">
			
		<div class="col_left">
			<div class="desktop-sidebar">
				<div class="sidebar">
					
				<?php
				if(is_active_sidebar('post_left_sidebar')){
					dynamic_sidebar('post_left_sidebar');
				}
				?>
				</div>
			</div>
			</div>
		<main id="main" class="site-main more-news col_center">
			<div class="archive-header">
				<?php
				the_archive_title( '<h1 class="page-title">', '</h1>' );
				the_archive_description( '<div class="archive-description">', '</div>' );
				?>
			</div><!-- .page-header -->
			<div class="feed">


		<?php if ( have_posts() )  {  ?>

<!-- 			<header class="page-header"> -->
				
	      <?php
         		// printf( '<h1 class="page-title text-center">More News</h1>' );
		?>
				
<!-- 			</header> -->
<!-- .page-header -->

			<?php
			/* Start the Loop */
			while ( have_posts() ) :
				the_post();
				$ID = get_the_ID();
				
	echo '<article class="post-section">';

				/**
				 * Run the loop for the search to output the results.
				 * If you want to overload this in a child theme then include a file
				 * called content-search.php and that will be used instead.
				 */
				echo '<h3><a href="'.get_the_permalink().'">'.get_the_title().'</a></h3>';
				//echo '<div class="entry-meta"><span class="post_date">'.get_the_date().'</span>'; 
				echo '<div class="entry-meta"><span class="post_date">'.date_format(date_create($post->post_date),"F d, Y").'</span>'; 
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
			$total_results = $wp_query->found_posts;
 		//	if($results->found_posts && $results->found_posts > 10){
		//if (isset($results)) $next_page_have_posts = $results->found_posts / $current_page;
			
 		//	if($next_page_have_posts > 0){
				echo '<div class="post-nav">';
				if (isset($wp_query)) echo next_posts_link('Older Posts', ceil($total_results/10));
				echo previous_posts_link('Newer Posts');
				echo '</div>';
 		//	}

 		//	}
}
		else {

			// get_template_part( 'template-parts/content', 'none' );

		}
		?>
			</div>
		</main><!-- #main -->
						<div class="right_col mobile-sidebar">
				<div class="sidebar">
					
				<?php
				if(is_active_sidebar('post_left_sidebar')){
					dynamic_sidebar('post_left_sidebar');
				}
				?>
				</div>
			</div>

			<div class="col_right">
				<div class="sidebar">
					
				<?php if(is_active_sidebar('post_right_sidebar')){
					dynamic_sidebar('post_right_sidebar');	
				} ?>
			
				</div>
			</div>
		</div>
			
	</section><!-- #primary -->

<?php
get_footer();
?>