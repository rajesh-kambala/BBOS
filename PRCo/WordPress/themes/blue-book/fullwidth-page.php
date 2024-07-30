<?php
/**
 * Template Name: Full Width Page
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

get_header();
?>

	<div id="primary" class="content-area grid-container">
		<div class="grid-x">
			
		<main id="main" class="site-main cell large-12 small-12 medium-12 column">

		<?php
		while ( have_posts() ) :
			the_post();

			get_template_part( 'template-parts/content', 'page' );

		

		endwhile; // End of the loop.
		?>

		</main><!-- #main -->
				
		</div>
	</div><!-- #primary -->
<style>
@media(max-width:800px){
	table td {
		display: block;
		width: 100%;
	}
}
</style>
<?php
get_footer();
