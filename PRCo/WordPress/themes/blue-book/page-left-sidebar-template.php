<?php
/**
 * Template Name: Left Sidebar Page
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

get_header();
?>

	<div id="primary" class="content-area grid-container">
		<div class="grid-x">
			<div class="cell large-3 small-12 medium-3 column desktop-sidebar sidebar">
				<?php 
				//dynamic_sidebar('page_sidebar'); 
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => ['our-history-left-sidebar'],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Our History Left Sidebar
				reblex_display_block($sidebars[0]);
				?>
			</div>
		<main id="main" class="site-main cell <?php echo is_page(array('4490', '4473', '4452', '4498'))?"large-6 small-12 medium-6":"large-9 medium-9";?> column">

		<?php
		while ( have_posts() ) :
			the_post();

			get_template_part( 'template-parts/content', 'page' );

		

		endwhile; // End of the loop.
		?>

		</main><!-- #main -->
				<div class="cell large-3 small-12 medium-3 column mobile-sidebar">
				<!--?php if(is_active_sidebar('post_left_sidebar')){
					dynamic_sidebar('page_sidebar');	
				} ?-->
			</div>
		</div>
	</div><!-- #primary -->
<script>
if(window.screen.width <= 800) {
	jQuery("#primary .desktop-sidebar").appendTo(".mobile-sidebar");
}

</script>
<?php
get_footer();
