<?php
/**
 * Template part for displaying page content in page.php
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<?php
	global $post;
	$post_slug = (isset($post) && $post != null)? $post->post_name : "";
	if($post_slug != "produce-newsletter")
	{
	?>
	<header class="entry-header">
		<?php the_title( '<h1 class="entry-title">', '</h1>' ); ?>
	</header><!-- .entry-header -->

	<?php 
	}
	
	//blue_book_services_post_thumbnail();
	if ( has_post_thumbnail()) : 
		echo '<div style="text-align:center;padding-top:10px;">';
		//the_post_thumbnail();
		$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post->ID ));
		$imageID = get_post_thumbnail_id($post->ID);
		$imagealt = get_post_meta($imageID, '_wp_attachment_image_alt', true);
		$imagetitle = get_the_title( $imageID );
		if($imagealt == "") $imagealt = $imagetitle;
		
		echo '<img src="'. $featured_image_url. '" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" title="'. $imagetitle. '" alt="'. $imagealt. '" style="max-width:100%;">';
		echo '</div>';
	endif;
	?>
	<div class="entry-content">
		<?php
		$content = get_the_content();
		$content = str_replace("https://apps.bluebookservices.com", BBSI_APPS, $content);
		$blocks = parse_blocks( $content );
		  foreach( $blocks as $block ) {
			  echo do_shortcode(render_block( $block ));
		  }

		wp_link_pages( array(
			'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'blue-book-services' ),
			'after'  => '</div>',
		) );
		?>
	</div><!-- .entry-content -->

	<?php if ( get_edit_post_link() ) : ?>
		<footer class="entry-footer">
			<?php
			edit_post_link(
				sprintf(
					wp_kses(
						/* translators: %s: Name of current post. Only visible to screen readers */
						__( 'Edit <span class="screen-reader-text">%s</span>', 'blue-book-services' ),
						array(
							'span' => array(
								'class' => array(),
							),
						)
					),
					get_the_title()
				),
				'<span class="edit-link">',
				'</span>'
			);
			?>
		</footer><!-- .entry-footer -->
	<?php endif; ?>
</article><!-- #post-<?php the_ID(); ?> -->
