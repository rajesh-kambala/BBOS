<?php
/*
Template Name: Get Listed Page Template
*/
?>
<?php get_header(); 
$rightsidebar_post = get_field('right_sidebar');
?>

<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>">

			<h2><?php the_title(); ?></h2>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">

				<?php the_content(); ?>

					<!--put iFrame here-->
					<iframe width="800px" height="1300px" seamless style="overflow: hidden;" scrolling="no" 
					   src="https://<?php echo $_SERVER['SERVER_NAME']; ?>/LumberPublicProfiles/GetListed.aspx"></iframe>  
					
					

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>

	<div class="int-sidebar right">
	<?php
		$content = $rightsidebar_post->post_content;
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
<script>
if(window.screen.width <= 800) {
	jQuery("iframe").css("max-width", "600px").css("min-height", "1300px");
}
</script>
