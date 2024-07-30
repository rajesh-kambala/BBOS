<?php
/*
Template Name: Get Listed Advertising Template
*/
?>
<?php get_header(); ?>

<script type="text/javascript" id="bbsiGetAdsWidget" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/GetAdsWidget.min.js"></script>     
    <script type="text/javascript">
        var licenseKey = "BBSIProduceAds";
        var pageName = "ProduceMarketingSite";

        var ad1 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "IA_960x100");
        //var ad2 = new BBSiGetAdsWidget("skyScraperAd1", licenseKey, pageName, 1, "IA_180x570");
        var ad3 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90,IA_180x570");
		
		setTimeout(function () {		
			var ad4 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90,IA_180x570");
		}, 300);
    </script>

<div class="wrap">

	<div class="top-banner">
	<!--top area for banner ad-->
	<span id="BBSIBNContent01" >
</div>

<div class="cat-sidebar left">

	<?php include ('get-listed-page-advertising-sidebar-left.php'); ?>
	
</div>

<section class="news-col left">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal-industry industry" id="post-<?php the_ID(); ?>">

			<h1><?php the_title(); ?></h1>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>



			<div class="entry">

				<?php the_content(); ?>

		

			</div>

			

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		

		<?php endwhile; endif; ?>

</section>

	<div class="news-sidebar left">

		<?php include('get-listed-page-advertising-sidebar-right.php'); ?>
	<?php //get_sidebar(); ?>
	</div>
<div class="clearfix"></div>

</div>

<?php get_footer(); ?>