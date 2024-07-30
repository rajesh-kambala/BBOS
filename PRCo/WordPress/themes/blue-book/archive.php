<?php
/**
 * The template for displaying archive pages
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

get_header();

global $wp;
$url = $_SERVER['REQUEST_URI'];
if (str_ends_with($url, '/know-your-produce-commodity/')) {
	header("Location: /know-your-produce-commodity-index/");
	die();	
}
?>




	<div id="primary" class="content-area grid-x">
		<div class="cell large-3 small-12 medium-3 column sidebar desktop-sidebar">
			<?php 
			//if(is_active_sidebar('post_left_sidebar')){
			//	dynamic_sidebar('post_left_sidebar');
			//}
			?>
		</div>
		<main id="main" class="site-main cell large-6 medium-6 small-12 column">

		<?php if ( have_posts() ) : ?>

			<header class="page-header">
				<?php
				the_archive_title( '<h1 class="page-title">', '</h1>' );
				the_archive_description( '<div class="archive-description">', '</div>' );
				?>
			</header><!-- .page-header -->

			<?php
			/* Start the Loop */
			while ( have_posts() ) :
				the_post();
				$ID = get_the_ID();
				$catarr = get_the_category();
				$descarr = get_post_meta($ID, 'short-description');
echo '<div class="archivepost">';
				/*
				 * Include the Post-Type-specific template for the content.
				 * If you want to override this in a child theme, then include a file
				 * called content-___.php (where ___ is the Post Type name) and that will be used instead.
				 */
// 				get_template_part( 'template-parts/content', get_post_type() );
				echo '<h4><a href="'.get_the_permalink().'">'.get_the_title().'</a></h4>';
			blue_book_services_posted_on(); 
			echo ' - '.((isset($catarr) && $catarr != null && count($catarr) > 0)? $catarr[0]->name : "");
 			
			echo '<span class="post-author">, ';
 				blue_book_services_posted_by();
			echo "</span>";
if(isset($descarr) && $descarr != null && count($descarr) > 0 && $descarr[0]){
	?>
	<div class="intro-text">
	<?php
	echo get_post_meta($ID,'short-description', true);

	?>
	</div>
	<?php
}else{
	the_excerpt();
}
 			
		echo '</div>';
				endwhile;

			the_posts_navigation();

		else :

			get_template_part( 'template-parts/content', 'none' );

		endif;
		?>

		</main><!-- #main -->
		<div class="cell large-3 small-12 medium-3 column sidebar mobile-sidebar">
			<?php 
			//if(is_active_sidebar('post_left_sidebar')){
			//	dynamic_sidebar('post_left_sidebar');
			//}
			?>
		</div>
		<div class="cell large-3 small-12 medium-3 column sidebar desktop-sidebar">
			<?php 
			//if(is_active_sidebar('post_right_sidebar')){
			//	dynamic_sidebar('post_right_sidebar');
			//}
			?>
		</div>
		
	</div><!-- #primary -->

<?php
get_footer();
