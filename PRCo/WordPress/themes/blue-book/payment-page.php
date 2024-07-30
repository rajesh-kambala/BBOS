<?php
/*
Template Name: Payment Page Template
*/
?>
<?php get_header(); ?>

<div class="wrap">

<script type="text/javascript">
  function resizeIframe(iframe) {
    iframe.height = iframe.contentWindow.document.body.scrollHeight + "px";
  }
</script>  



	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>">
		
			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
				<?php the_content(); ?>

					<iframe sandbox="allow-same-origin allow-top-navigation allow-forms allow-scripts allow-modals" 
					        height="750px" width="1000px" seamless style="overflow: hidden;" scrolling="no" 
							src="https://<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/Payment.aspx?CompanyID=<?php echo ((isset($_GET['c']))? $_GET['c'] : ""); ?>">
					</iframe>  

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
	

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
