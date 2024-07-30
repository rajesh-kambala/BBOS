<?php get_header(); ?>

    <script type="text/javascript">
        var licenseKey = "BBSIProduceAds";
        var pageName = "ProduceMarketingSite";

        var ad1 = new BBSiGetAdsWidget("bannerAd1", licenseKey, pageName, 1, "IA_960x100");
        var ad2 = new BBSiGetAdsWidget("skyScraperAd1", licenseKey, pageName, 1, "IA_180x570");
        var ad3 = new BBSiGetAdsWidget("otherAds1", licenseKey, pageName, 3, "IA,IA_180x90");
		
		setTimeout(function () {		
			var ad4 = new BBSiGetAdsWidget("otherAds2", licenseKey, pageName, 4, "IA,IA_180x90");
		}, 300);		
        
    </script>

<div class="wrap">

<div class="top-banner">
	<!--top area for banner ad-->
	<span id="bannerAd1" >
</div>

<div class="cat-sidebar left">

	<?php include('sidebar-left.php'); ?>

</div>


	<section class="news-col left">
		<?php if ($pagename == "news") { echo '<div class="sidebarText">'.do_shortcode( '[smartblock id=1767]' ).'</div>'; } ?>
<?php if(is_home() && !is_paged()) { ?>
<?php query_posts(array('post__in'=>get_option('sticky_posts'))); ?>



<?php while (have_posts()) : the_post(); ?>

	<?php if ( has_post_thumbnail()) : ?>
	
	<?php $img = wp_get_attachment_image_src( get_post_thumbnail_id( $page->ID ), 'full' ); ?>


<!--  This is New standforst 09/21/2016 -->
<article id="post-<?php the_ID(); ?>">
<div class="featured_img"><img src="<?php echo $img[0]; ?>"></div>
<div class="featured">
<span style="font-size: 1.1em">
	<h2><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></h2>
<div class="entry-title"><?php echo get_post_meta($post->ID, 'standfirst', true) ?></div><br />

<time datetime="<?php echo date(DATE_W3C); ?>" pubdate class="updated"><?php the_time('F jS, Y') ?></time> - <?php $category = get_the_category(); echo $category[0]->cat_name; ?>
				<?php $categoryList = get_the_category(); ?>
				<?php if ( $categoryList[0]->cat_name == 'Blueprints' ) {  ?>
					<!-- <a href="/blog/category/<?php echo $categoryList[0]->slug  ?>">--><?php the_cfc_field('blueprintEdition','date'); ?> Edition<!-- </a> -->
				<?php } ?>
<br /><br />

<div class="entry"><?php the_excerpt(); ?></div>
			</span>
<!--  This is disabled Standfirst for Sticky Article 
<h3><?php echo get_post_meta($post->ID, 'standfirst', true) ?> <a href="<?php the_permalink() ?>">Read More</a></h3>
-->
</div>
</article>
<!--  End of new standfirst 09/21/2016 -->



<?php else : ?>



<!--  No Image Sticky Section -->

<article id="post-<?php the_ID(); ?>" class="featured noimage" >
<span style="font-size: 1.1em">
	<h2><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></h2>
<div class="entry-title"><?php echo get_post_meta($post->ID, 'standfirst', true) ?></div><br />

<time datetime="<?php echo date(DATE_W3C); ?>" pubdate class="updated"><?php the_time('F jS, Y') ?></time> - <?php $category = get_the_category(); echo $category[0]->cat_name; ?>
				<?php $categoryList = get_the_category(); ?>
				<?php if ( $categoryList[0]->cat_name == 'Blueprints' ) {  ?>
					<!-- <a href="/blog/category/<?php echo $categoryList[0]->slug  ?>">--><?php the_cfc_field('blueprintEdition','date'); ?> Edition<!-- </a> -->
				<?php } ?>
<br /><br />

<div class="entry"><?php the_excerpt(); ?></div>
			</span>
<!--  This is disabled Standfirst for Sticky Article 
<h3><?php echo get_post_meta($post->ID, 'standfirst', true) ?> <a href="<?php the_permalink() ?>">Read More</a></h3>
-->
</article>


<?php endif; ?>
<?php endwhile; ?>


	<?php wp_reset_query(); ?>
	<?php }; ?>
	<div class="news-index">

	<?php query_posts(array("post__not_in" =>get_option("sticky_posts"), 'paged' => get_query_var('paged'))); ?>	
	<?php if (have_posts()) : ?>
		<?php while (have_posts()) : the_post(); ?>

		
		<article <?php post_class() ?> id="post-<?php the_ID(); ?>">

			<h2><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></h2>

			<span class="byline author vcard cat fn"><time datetime="<?php echo date(DATE_W3C); ?>" pubdate class="updated"><?php the_time('F jS, Y') ?></time> - <?php $category = get_the_category(); echo $category[0]->cat_name; ?>
				<?php $categoryList = get_the_category(); ?>
				<?php if ( $categoryList[0]->cat_name == 'Blueprints' ) {  ?>
					<!-- <a href="/blog/category/<?php echo $categoryList[0]->slug  ?>">--><?php the_cfc_field('blueprintEdition','date'); ?> Edition<!-- </a> -->
				<?php } ?>
			</span>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">
				<?php the_excerpt(); ?>
			</div>

			<footer class="postmetadata">
				<?php the_tags('Keywords: ', ', '); ?>
				<!-- Posted in <?php //the_category(', ') ?>  -->
				<?php //comments_popup_link('No Comments &#187;', '1 Comment &#187;', '% Comments &#187;'); ?>
			</footer>

		</article>

	<?php endwhile; ?>

	<?php include (TEMPLATEPATH . '/_/inc/nav.php' ); ?>

	<?php else : ?>

		<h2>Not Found</h2>

	<?php endif; ?>

	<?php wp_reset_query(); ?>

	</div>

	</section>

<div class="news-sidebar left">

<?php include('sidebar-right.php'); ?>

</div>

<div class="clearfix"></div>

</div>

<?php get_footer();
$guid = GUID();
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA_960x100" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA_180x570" maxcount="1" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="3" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="4" webuserid="0" industrytype="P" guid="'. $guid. '"]');
?>