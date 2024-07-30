<?php
/**
 * The template for displaying all pages
 *
 * This is the template that displays all pages by default.
 * Please note that this is the WordPress construct of pages
 * and that other 'pages' on your WordPress site may use a
 * different template.
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

get_header();
global $post;
$post_slug = (isset($post) && $post != null)? $post->post_name : "";
if($post_slug == "know-your-produce-commodity-index")
{
?>
<style>
	article {
		margin-top: 69.84px !important;
	}
	article .grid-x .cell {
		/*height: 160px;*/
	}
</style>
<?php } ?>
	<div id="primary" class="content-area">
		<div class="grid-x">
			<?php 
			$leftsidebar_post = get_field('left_sidebar');
			if(is_object($leftsidebar_post) && $leftsidebar_post->post_title != "Blank")
			{
			?>
			<div class="cell large-3 small-12 medium-3 column desktop-sidebar sidebar">
				<?php 
				$content = $leftsidebar_post->post_content;
				$blocks = parse_blocks( $content );
				  foreach( $blocks as $block ) {
					//if( 'core/quote' === $block['blockName'] ) {
					  echo do_shortcode(render_block( $block ));
					  //break;
					//}
				  }
				?>
			</div>
			<?php  } ?>
		<main id="main" class="site-main cell <?php echo is_page(array('364', '326', '374', '4498'))?"large-6 small-12 medium-6":"large-9 medium-9";?> column">

		<?php
		while ( have_posts() ) :
			the_post();

			get_template_part( 'template-parts/content', 'page' );

		endwhile; // End of the loop.
		?>

		</main><!-- #main -->
			<?php 
			$rightsidebar_post = get_field('right_sidebar');
			//if(is_page(array('364', '326', '374'))){
			if(is_object($rightsidebar_post) && $rightsidebar_post->post_title != "Blank")
			{
			?>
				<!--div class="cell large-3 small-12 medium-3 column mobile-sidebar"-->
				<div class="cell large-3 medium-3 small-12 sidebar" style="text-align:center;">
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
			<?php 
			} 
			?>
		</div>
	</div><!-- #primary -->

<?php
//echo $post->ID;
get_footer();
/*
$guid = GUID();
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="3" webuserid="0" industrytype="P" guid="'. $guid. '"]');
echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="IA,IA_180x90" maxcount="4" webuserid="0" industrytype="P" guid="'. $guid. '"]');
*/
?>
<script src="<?php bloginfo('template_directory'); ?>/js/page.js?v=1.0" type="text/javascript"></script>