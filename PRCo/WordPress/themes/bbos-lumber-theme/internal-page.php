<?php
/*
Template Name: Internal Page Template
*/
?>
<?php get_header(); ?>

<div class="wrap" style="display:flex;">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>" style="width: 100%; max-width: 880px;">

			<h2><?php the_title(); ?></h2>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">

				<?php
				$content = get_the_content();
				$content = str_replace("https://apps.bluebookservices.com", BBSI_APPS, $content);
				$blocks = parse_blocks( $content );
				  foreach( $blocks as $block ) {
					  echo do_shortcode(render_block( $block ));
				  }
				?>

				<?php //wp_link_pages(array('before' => 'Pages: ', 'next_or_number' => 'number')); ?>

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>

	<div class="int-sidebar right">
	<?php 
	//get_sidebar('intsidebar');
	$rightsidebar_post = get_field('right_sidebar');
	$content = (($rightsidebar_post != null)? $rightsidebar_post->post_content : "");
	$blocks = parse_blocks( $content );
	  foreach( $blocks as $block ) {
		//if( 'core/quote' === $block['blockName'] ) {
		  echo do_shortcode(render_block( $block ));
		  //break;
		//}
	  }
	?>
	</div>
<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
<style>
@media(max-width:800px){
	#colvid, #colvidtext {
		display: block;
		width: 100%;
	}
}
@media(max-width:600px){
	.wrap {
		display: block !important;
	}
	.entry p {
		height: auto !important;
		margin-bottom: 20px;
	}
	.wp-block-image {
		display: block;
		float: none;
		overflow: auto;
		width: 160px;
		margin: 0 auto !important;
	}
	.wp-block-group {
		width: 100%;
		display: block;
		overflow: auto;
	}
}
.youtubetitle, .clearfix {
	clear: both;
}
</style>