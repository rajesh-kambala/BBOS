<?php
/*
Template Name: Industry Links Template
*/
?>
<?php get_header(); ?>


<div class="wrap grid-x">

	<div class="top-banner">
	<!--top area for banner ad-->
</div>
				<div class="cell large-3 small-12 medium-3 column desktop-sidebar sidebar" style="text-align: center;">
				<?php 
				$leftsidebar_post = get_field('left_sidebar');

				if(isset($leftsidebar_post) && $leftsidebar_post != null)
				{
					$content = $leftsidebar_post->post_content;
					$blocks = parse_blocks( $content );
					  foreach( $blocks as $block ) {
						//if( 'core/quote' === $block['blockName'] ) {
						  echo do_shortcode(render_block( $block ));
						  //break;
						//}
					  }
				}
			?>
			</div>
<div class="cell large-6 medium-6 small-12 column">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal-industry industry" id="post-<?php the_ID(); ?>">
			<div id="BBSIBNContent01"></div>
			<h1><?php the_title(); ?></h1>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>



			<div class="entry">

				<?php the_content(); ?>
				
				<?php 
				if(get_post_meta( $post->ID, 'industrylinks', true )){
					?>
				<ul class="accordion accordion-linkitems" data-multi-expand='true' data-allow-all-closed='true' data-accordion>

				<?php
					$link_item_number = 0;
					foreach(get_post_meta( $post->ID, 'industrylinks', true ) as $itemac){
 						
?>						
						  <li class="accordion-item" data-accordion-item>
							
 							  <a href="#" class="accordion-title"><?php 
echo  $itemac['industry-title']; ?></a>
			  <div class="accordion-content" data-tab-content> 
								   <p> 
								 
 							  <img src="<?php 
echo wp_get_attachment_image_src($itemac['industry-image'], 'grid-large')[0]; ?>"  /></p> 
								  <?php 
 				echo $itemac['industry-description']; ?>
							  </div>

					</li>
					<?php
						
					}
					?>
				</ul>
				<div id="BBSIBAContent01" style="text-align: center; margin-top: 20px;"></div>
				<?php 
			}
				?>

				<?php //wp_link_pages(array('before' => 'Pages: ', 'next_or_number' => 'number')); ?>

			</div>

			

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		

		<?php endwhile; endif; ?>

</div>
			<!--div class="cell large-3 small-12 medium-3 column mobile-sidebar sidebar">
				<?php 
				//dynamic_sidebar('post_left_sidebar'); 
				?>
			</div-->
			
	<div class="cell large-3 medium-3 small-12 column sidebar">
<div id="BBSISDContent01" style="text-align: center;"></div>
		<?php 
			$rightsidebar_post = get_field('right_sidebar');

			if($rightsidebar_post != null)
			{
				$content = $rightsidebar_post->post_content;
				$blocks = parse_blocks( $content );
				  foreach( $blocks as $block ) {
					//if( 'core/quote' === $block['blockName'] ) {
					  echo do_shortcode(render_block( $block ));
					  //break;
					//}
				  }
			}
		?>
	</div>

</div>

<?php get_footer(); ?>
    <script type="text/javascript">
	setTimeout(function() {
		if(window.screen.width <= 800) {
			jQuery("#BBSISDContent01").parent().insertAfter(jQuery("article .entry p:nth-child(2)")[0]);
			setTimeout(function() {jQuery("#BBSIBAContent01 img").css("width", "354px");}, 100);
			jQuery("<div id=\"BBSISQContent02\" style=\"position: relative;\"></div>").insertBefore("#BBSIBNContent02");
			jQuery("<div id=\"BBSISQContent03\" style=\"position: relative;\"></div>").insertAfter("#BBSIBNContent02");
		}
		else {
			//jQuery("<div id=\"BBSISQContent02\" style=\"position: relative;\"></div>").insertBefore("#swboc-21");
			//jQuery("<div id=\"BBSISQContent03\" style=\"margin-top: 10px; position: relative;\"></div>").insertAfter("#BBSIOAContent01");
		}
		
        var licenseKey = "BBSIProduceAds";
        var pageName = "ProduceMarketingSite";
		
		jQuery("#BBSIBNContent01").insertAfter("#BBSIBAContent01");
		jQuery("#BBSIBAContent01").insertBefore("article h2");
				
        var ad1 = new BBSiGetAdsWidget("BBSIBAContent01", licenseKey, pageName, 1, "PMSHPB");
        var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB3");
		var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
        var ad4 = new BBSiGetAdsWidget("BBSISQContent02", licenseKey, pageName, 1, "PMSHPSQ2");
        var ad5 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ3");
        //var ad7 = new BBSiGetAdsWidget("BBSIBAContent01", licenseKey, pageName, 1, "PMSHPB3");
        var ad8 = new BBSiGetAdsWidget("BBSILBContent01", licenseKey, pageName, 1, "IA");
		var ad31 = new BBSiGetAdsWidget("BBSISDContent01", licenseKey, pageName, 1, "PMSHPSQ");
 
		if (jQuery("#BBSIOAContent01").length) {
			var ad1 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90");
		}
		
		if (jQuery("#BBSIOAContent02").length) {
			setTimeout(function () {		
				var ad2 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
			}, 300);
		}
	}, 100);
    </script>