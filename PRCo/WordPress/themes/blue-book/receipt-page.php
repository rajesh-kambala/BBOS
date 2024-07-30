<?php
/*
Template Name: Receipt Page Template
*/
?>
<?php get_header(); ?>

<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>">

			<h2><?php the_title(); ?></h2>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">
				<?php the_content(); ?>
					<script>
						window.addEventListener('message', function(event) {
						  if(height = event.data['height']) {
							$('iframe').css('height', height + 'px')
						  }
						})
					</script>
					
					<iframe sandbox="allow-same-origin allow-top-navigation allow-modals allow-forms allow-scripts allow-popups" 
					        height="2900px" width="600px" seamless style="overflow: hidden; height:2900px;" scrolling="no" 
							src="https://<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/BOR.aspx?lang=en-us" 
							onload="if($(this.contentWindow.document.body).find('#BORContent').length>0) { $(this).height($(this.contentWindow.document.body).find('#BORContent').height());};" >
					</iframe> 
			</div>			

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>

	<!--<div class="int-sidebar right">-->
	<?php 
	//get_sidebar('intsidebar'); 
	?>
	<!--</div>-->
<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
