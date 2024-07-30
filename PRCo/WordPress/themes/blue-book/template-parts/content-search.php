<?php
/**
 * Template part for displaying results in search pages
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<header class="entry-header">
		<?php the_title( sprintf( '<h3 class="entry-title"><a href="%s" rel="bookmark">', esc_url( get_permalink() ) ), '</a></h3>' ); ?>

		<?php if ( 'post' === get_post_type() ) : ?>
		<div class="entry-meta">
			<?php
			blue_book_services_posted_on();
			blue_book_services_posted_by();
			?>
		</div><!-- .entry-meta -->
		<?php endif; ?>
	</header><!-- .entry-header -->

	<?php
	//blue_book_services_post_thumbnail(); 
	?>

		<?php
$ID = get_the_ID();
$shortarr = get_post_meta($ID, 'short-description');
if(isset($shortarr) && $shortarr != null && count($shortarr) > 0 && $shortarr[0]){
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
?>
	
		<?php
		//blue_book_services_entry_footer(); 
		?>
</article><!-- #post-<?php the_ID(); ?> -->
