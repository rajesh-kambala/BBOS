<?php
/**
 * Template part for displaying posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<header class="entry-header">
		<?php
		if ( is_singular() ) :
			the_title( '<h1 class="entry-title">', '</h1>' );
			 echo '<h5>'.get_post_meta(get_the_ID(),'standfirst', true).'</h5>';
		else :
			the_title( '<h2 class="entry-title"><a href="' . esc_url( get_permalink() ) . '" rel="bookmark">', '</a></h2>' );
		endif;

		if ( 'post' === get_post_type() ) :
			?>
			<div class="entry-meta">
				<?php
				blue_book_services_posted_on(); 
				echo ' - '.get_the_category()[0]->name;
// 				blue_book_services_posted_by();
 				?>
				
 					<div class="buttons share-btn-kyc">		
		<a class="print" href="?print=yes"><i class="fa fa-print"></i> Print</a> &nbsp; 
		<a class="email" href="mailto:?subject=<?php echo get_the_title();?>&body=From%20Blue%20Book%20Services:%0D%0A%0D%0A<?php echo get_the_title();?>%0D%0A%0D%0A<?php echo get_the_permalink(); ?>%0D%0A%0D%0A"><i class="fa fa-envelope-o"></i> Email</a>
		&nbsp; <?php echo do_shortcode('[addtoany]'); ?>
	</div>
				<?php
				
				if(get_post_meta(get_the_ID(),'date')[0]){
					echo '<div class="bp-edition-date">Blueprints Edition Date: '.get_post_meta(get_the_ID(),'date', true).' </div>';	
				} ?>
			</div><!-- .entry-meta -->
		<?php endif; ?>
	</header><!-- .entry-header -->

	<?php 
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
	<small><?php the_post_thumbnail_caption(); ?></small>

	<div class="entry-content">
	

		<?php
		
		the_content( sprintf(
			wp_kses(
				/* translators: %s: Name of current post. Only visible to screen readers */
				__( 'Continue reading<span class="screen-reader-text"> "%s"</span>', 'blue-book-services' ),
				array(
					'span' => array(
						'class' => array(),
					),
				)
			),
			get_the_title()
		) );

						wp_pagenavi( array( 'type' => 'multipart' ) );
// wp_link_pages( array(
// 			'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'blue-book-services' ),
// 			'after'  => '</div>',
// 		) ); 
		?>
	</div><!-- .entry-content -->
<?php if(isset($_GET['print']) && $_GET['print']  == 'yes') {
					echo apply_filters('the_content',$post->post_content);  ?>


					<script type="text/javascript">
						 window.onload = function() { window.print(); }
						 setTimeout(function(){ window.history.back(); },1000);
					</script>

				<?php
}?>
	<footer class="entry-footer">
		<?php blue_book_services_entry_footer(); ?>
	</footer><!-- .entry-footer -->
</article><!-- #post-<?php the_ID(); ?> -->
