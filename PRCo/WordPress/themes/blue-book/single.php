<?php
/**
 * The template for displaying all single posts
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/#single-post
 *
 * @package Blue_Book_Services
 */

get_header();
?>
<style>
	article {
		margin-top: 69.84px;
	}
</style>
	<div id="primary" class="content-area grid-container">
		<div class="grid-x">
			<div class="cell large-3 small-12 medium-3 sidebar desktop-sidebar">
				<?php
				//echo do_shortcode('[getAdsWidget key="BBSIProduceAds" pagename="ProduceMarketingSite" adtypes="PMSHPSQ2" maxcount="3" mobiledevice="false" webuserid="0" industrytype="P"]');
				?>

				<?php 
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');	
				//}
				$args = [
					'post_type'      => 'wp_block',
					'posts_per_page' => 1,
					'post_name__in'  => [((isset($_REQUEST["s"]))? 'search-left-side-bar' : 'article-left-side-bar')],
					'fields'         => 'ids'
				];
				$sidebars = get_posts( $args );
				
				// Article Left Sidebar
				reblex_display_block($sidebars[0]);
				?>
			</div>
			<main id="main" class="site-main cell large-6 small-12 medium-6">
				<div id="BBSIBNContentDIV" class="cell large-12" style="text-align:center; padding-top: 0;">
					<section id="swboc-119a" class="widget SWBOC_Widget leaderboard"><div id="BBSIBNContent01" style="text-align: center;"></div>
					</section>
				</div>

		<?php
		while ( have_posts() ) :
				the_post();
				wpb_set_post_views(get_the_ID());

			get_template_part( 'template-parts/content', get_post_type() );

//	the_post_navigation();

		

		endwhile; // End of the loop.
		?>
				<?php $pageLength = count($pages);
					  $url = $_SERVER['REQUEST_URI'];

					  $explodedURI = explode('/', $url);
					  end($explodedURI);
					  prev($explodedURI);
					  $keyTar = current($explodedURI);


					 if ($keyTar == $pageLength || $pageLength == '1') { ?>
				<?php 
				$ID = get_the_ID();
				$aboutauthorarr = get_post_meta($ID, 'about-author',);
				if(count($aboutauthorarr) > 0 && $aboutauthorarr[0]){ ?>
					 <p class="author-box">		
						<?php echo get_post_meta($ID,'about-author',true ); ?>
					</p>
				<?php } ?>
					 	
				<?php	 }

				?>
				<div class="cell large-12" style="text-align:cente; padding:20px 0;padding-top: 0;">
					<section id="swboc-119b" class="widget SWBOC_Widget leaderboard"><div id="BBSIBNContent03" style="text-align: center;"></div>
					</section>
				</div>

				<div class="related_posts">
			<h3>Related Posts</h3>
	<?php
		$count = 10;

		$tags = wp_get_post_tags(get_the_ID());
		$tag_id_array = array();
		foreach ($tags as $tag) {
			$tag_id_array[] = $tag->term_id;
		}
		$queryargs = array(
			'tag__in' => $tag_id_array,
			'posts_per_page' => $count,
			'post__not_in' => array(get_the_ID()),
			'order'=> 'DESC',
			'orderby' => 'date'
		);

		$related_posts = new WP_Query($queryargs);
		$related_posts_html = '';
		?>
	
<?php

			$added_ids = array();
			$countposts = 1;
			while($related_posts->have_posts()){
			$related_posts->the_post();
			if($countposts < 6){
			if(!in_array(get_the_ID(), $added_ids ,true)){
			$added_ids[] = get_the_ID();
			$countposts++;
			?>
			<div class="rp_col">
			<?php	echo '<a href="'.get_the_permalink().'">'.get_the_title().'</a>'; ?>
			<div class="post_content">
						<div class="entry-meta">
								<?php
								blue_book_services_posted_on();
								blue_book_services_posted_by();
								?>
							</div><!-- .entry-meta -->
						</div>
					</div>
							<?php
		}
		}
		}
		
		?>
			
	
</div>

		</main><!-- #main -->
			<div class="cell large-3 small-12 medium-3 sidebar mobile-sidebar">
				<?php 
				//if(is_active_sidebar('post_left_sidebar')){
				//	dynamic_sidebar('post_left_sidebar');	
				//} 
				reblex_display_block($sidebars[0]);
				?>
			</div>
			<div class="cell large-3 medium-4 small-12 sidebar">
				<?php 
					//if(is_active_sidebar('post_right_sidebar')){
					//dynamic_sidebar('post_right_sidebar');	
					//} 
					
					// Article Right Sidebar
					$args = [
						'post_type'      => 'wp_block',
						'posts_per_page' => 1,
						'post_name__in'  => ['article-right-sidebar'],
						'fields'         => 'ids'
					];
					$sidebars = get_posts( $args );
					reblex_display_block($sidebars[0]);
				?>
			</div>
		</div>
	</div><!-- #primary -->
<?php get_footer(); ?>
<script src="<?php bloginfo('template_directory'); ?>/js/single.js?v=1.0" type="text/javascript"></script>

