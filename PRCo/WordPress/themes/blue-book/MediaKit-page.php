<?php
/**
 * Template Name: MediaKit Page
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

get_header();
?>
<style>
	article ul li {
		margin-left: 0.25em;
	}
</style>


	<div id="primary" class="content-area grid-container">
		<div class="grid-x">
			
		<main id="main" class="site-main cell large-12 small-12 medium-12 column">

		<?php
		while ( have_posts() ) :
			the_post();

			get_template_part( 'template-parts/content', 'mediakit' );

		

		endwhile; // End of the loop.
		?>

		</main><!-- #main -->
				
		</div>
	</div><!-- #primary -->

<?php
get_footer();
