<?php
/*
Template Name: Get Listed Page Template
*/
?>
<?php get_header(); ?>

<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			<div class="grid-x grid-container">
				
		<article class="internal cell large-9 medium-8 small-12 column" id="post-<?php the_ID(); ?>">

			<h1><?php the_title(); ?></h1>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">

				<?php the_content(); ?>

					<!--put iFrame here-->
					<iframe width="800px" height="1000px" seamless style="overflow: hidden;" scrolling="no" 
					   src="//<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/GetListed.aspx"></iframe>  
			
			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		
		<?php endwhile; endif; ?>

	<div class="cell large-3 medium-6 small-12 column sidebar">
		<?php 
		//get_sidebar(); 
			$rightsidebar_post = get_field('right_sidebar');
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
	</div>
	</div>
<div class="clearfix"></div>

</div>
<?php 
get_footer();
/*
$guid = GUID();
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
*/
?>
<script>
var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";
var ad8 = new BBSiGetAdsWidget("BBSILBContent01", licenseKey, pageName, 1, "IA");

if(window.screen.width <= 800) {
	jQuery("iframe").css("max-width", "600px").css("min-height", "1400px");
}
</script>


