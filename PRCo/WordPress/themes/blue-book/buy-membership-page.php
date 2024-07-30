<?php
/*
Template Name: Buy Membership Page Template
*/
?>
<?php get_header(); ?>
<script>setButtonClick();</script>

<div class="wrap">
	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>">
			<h1>Join Today - Blue Book Membership</h1>
			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
			<div class="entry">
				<?php the_content(); ?>

					<iframe id="MemberSelect" sandbox="allow-same-origin allow-top-navigation allow-forms allow-scripts allow-popups allow-modals" 
					        height="1150px" width="1000px" seamless style="overflow: hidden;" scrolling="no" 
							src="//<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/MembershipSelect.aspx?lang=en-us" >
					</iframe>  

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
	
	

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
