<?php
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
/*
Template Name: Company Directory Page Template
*/
get_header();
?>
<div class="wrap">
<style>
	.internal ul li {
		list-style-type: none;
	}
	.internal ul li a {
		text-decoration: none;
	}
</style>



	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
		<article class="internal landingpage" style="width: 100%; max-width: 880px;">
		<?php
		//while ( have_posts() ) :
//
		if(!isset($_REQUEST["begin"]))
		{
		?>
	<?php
	global $post;
	$post_slug = (isset($post) && $post != null)? $post->post_name : "";
	if($post_slug != "produce-newsletter")
	{
		the_title( '<h2>', '</h2>' );
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
		<?php
		the_content();

		wp_link_pages( array(
			'before' => '<div class="page-links">' . esc_html__( 'Pages:', 'blue-book-services' ),
			'after'  => '</div>',
		) );
		?>

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
	</article><!-- #post-'<?php the_ID(); ?> -->
	<?php
		}
		else
		{
			echo '<p>The purpose of this page is to provide all listed companies in the Blue Book Services database extra exposure and branding via search engines. If you have come to this page for a specific company or a list of companies and you are a Blue Book Member, please <a href="https://apps.bluebookservices.com/BBOS/Login.aspx">sign into Blue Book Online Services</a> (BBOS) for more comprehensive information and search capabilities.</p>';
			global $wpdb;
			$rows = $wpdb->get_results( "EXEC usp_CompanySearchByFirstLetter '". $_REQUEST["begin"]. "'" );
			echo '<div><ul style="list-style-type: none;">';
			for($idx = 0; $idx < count($rows); $idx++)
			{
				echo '<li style="float:left; width:30%;"><a href="'. str_replace("find-produce-companies", "services/find-companies", $rows[$idx]->prce_WordPressSlug). '">'. $rows[$idx]->comp_PRCorrTradestyle. '</a></li>';
			}
			echo '</ul>
			</div>
			<p style="clear:both;">For those seeking more information about Blue Book membership, please contact us. Our representatives will be happy to help determine how a Blue Book Services membership can best be used to expand and support any business.</p>
			';
		}

		//endwhile; // End of the loop.
		?>

					<!--iframe sandbox="allow-same-origin allow-top-navigation allow-forms allow-scripts" 
					        height="600px" width="1000px" seamless style="overflow: hidden;" scrolling="no" 
							src="//<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/Default.aspx">
					</iframe-->  

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
