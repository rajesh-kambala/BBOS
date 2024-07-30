<?php
/**
 * The template for displaying home page
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
?>
<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/css/frontpage.css?v=1.0">
	<div id="primary" class="content-area" style="padding-bottom: 20px;">
		<div class="bbsiHidden">
			<h1>Produce Blue Book</h1>
		</div>
		<main id="main" class="site-main grid-x">
			<div class="cel large-3 small-12 column sidebar">
				<?php 
					//if(is_active_sidebar('hp_left_sidebar')){
					//	dynamic_sidebar('hp_left_sidebar');
					//}
					
					// Home Page Left Sidebar
					$leftsidebar_post = get_field('left_sidebar');
					$rightsidebar_post = get_field('right_sidebar');
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
			<div class="cell large-6 small-12 column" style="padding-left: 10px; padding-right: 10px;">
			<?php 	$mobiledetect = new Mobile_Detect;
					$isMobileDevice = $mobiledetect->isMobile() ? 1 : 0;
			?>
				<div id="BBSIBNContent01"<?php if($isMobileDevice) { echo ' style="display: block !important; height: 261px !important;"';} ?>></div>
				
				<div class="cell large-12" style="text-align:center; padding:20px 0; display:none;">
					<?php if(is_active_sidebar('ad_sidebar')){
							dynamic_sidebar('ad_sidebar');
					} ?>
				</div>
		<?php
			//get featured post for 
			$featured_posts = new WP_query(array(
				'posts_per_page'=>1,
				'category_name'=> 'featured',
				'orderby' => 'post_date',
				'order' => 'DSC'
			));
			//get recent posts other than featured post
			$recent_posts = get_posts(array(
				'numberposts'=>4,
				'category'=> get_cat_ID('featured'),
				'exclude' => array(get_the_ID()),
				'orderby' => 'post_date',
				'order' => 'DSC'
			));
			
		while ($featured_posts->have_posts() ) :
				setup_postdata($featured_posts);
			$featured_posts->the_post();
			?>
				<div class="featured_post grid-x">
					<div><a href="<?php echo get_the_permalink(); ?>"><h3><?php echo get_the_title(); ?></h3></a></div>
					<div class="cell large-7 column">
					<div><?php 
					//the_post_thumbnail(); 
					//echo $post->ID;
					$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post->ID ));
					$imageID = get_post_thumbnail_id($post->ID);
					$imagealt = get_post_meta($imageID, '_wp_attachment_image_alt', true);
					$imagetitle = get_the_title( $imageID );
					if($imagealt == "") $imagealt = $imagetitle;
					
					echo '<img src="'. $featured_image_url. '" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" title="'. $imagetitle. '" alt="'. $imagealt. '" style="max-width:100%;">';
					?>
					</div>
					</div>
					<div class="cell large-5 column post_content_section">
						<p>
						<?php

							if(get_post_meta(get_the_ID(), 'short-description')[0]){

								echo get_post_meta(get_the_ID(),'short-description', true);
							}else{
							$content = get_the_content();
							echo substr($content, 0, 200); 
							}
						?>
						</p>
						<a href="<?php echo get_the_permalink(); ?>">Read More...</a>
						
				<?php /*
            foreach($recent_posts as $recent_post){
							echo '<p class="fp_recent_posts"><a href="'.get_post_permalink($recent_post->ID).'">'.$recent_post->post_title.'</a></p>'; */
							
						?>
						<?php //} 
						?>
					</div>
				</div>
				<?php if($isMobileDevice) { echo '<div id="BBSISQContent01" style="text-align: center; padding-top: 20px;"></div>';} ?>
				<?php
// 			get_template_part( 'template-parts/content', 'page' );

		

		endwhile; // End of the loop.
			wp_reset_postdata();
		?>
		
		<div class="cell large-12" style="text-align:center; padding:20px 0;">
					<section id="swboc-120" class="widget SWBOC_Widget"><div id="BBSIBNContent03" style="text-align: center;"></div>
</section>				</div>


		<div class="cell large-12 grid-x" style="width: 100%; height: 100%; max-width: 565px; height: 414.71px;">
			<div class="cell large-12 feed">
				<div class="cell large-12">
					<h2 style="margin-bottom: 10px;">
						Featured Video
					</h2>
				</div>
				<div class="cell large-12">
					<!--iframe src="https://www.youtube.com/embed/nWAzQAh1Tww" scrolling="yes" class="iframe-class" width="100%" frameborder="0"></iframe-->
					<!--?php echo do_shortcode( '[fts_youtube vid_count=4 large_vid=yes large_vid_title=no large_vid_description=no thumbs_play_in_iframe=yes vids_in_row=4 omit_first_thumbnail=no space_between_videos=1px force_columns=no maxres_thumbnail_images=yes thumbs_wrap_color=#000 channel_id=UCMrlVvzRKuvm9mhKgmHT_Tg]' ); ?-->
					<!--?php echo do_shortcode('[embedyt]https://www.youtube.com/channel/UCMrlVvzRKuvm9mhKgmHT_Tg[/embedyt]'); ?-->
					<?php
					//$youtube_channel_page = file_get_contents('https://www.youtube.com/@ProducewithPamela/videos');
					$ch = curl_init();
					curl_setopt($ch, CURLOPT_URL, 'https://www.youtube.com/@ProducewithPamela/videos');
					curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
					curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
					$youtube_channel_page = curl_exec($ch);
					curl_close ($ch);
					$youtube_channel_page_array = explode("watch?v=", $youtube_channel_page);
					$video_url_array = explode('"', $youtube_channel_page_array[1]);
					//echo $homepage;
					?>
					<iframe id="FeaturedVideoFrame" src="https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg" allow="autoplay" style="height:280px;padding:0;"></iframe>
					<div id="FeaturedVideoIcons" style="width:100%; display: table; height: 50px;">
						<div style="width:25%; display: none; position:relative; padding:0 1px;" onclick="jQuery('#FeaturedVideoFrame').attr('src', 'https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg&autoplay=1'); jQuery('#FeaturedVideoIcons div').css('display', 'table-cell'); jQuery(this).hide();">
							<img src="https://img.youtube.com/vi/<?php echo explode('"', $youtube_channel_page_array[1])[0]; ?>/0.jpg" style="width:100%; cursor:pointer;" />
						</div>
						<div style="width:25%; display: table-cell; position:relative; padding:0 1px;" onclick="jQuery('#FeaturedVideoFrame').attr('src', 'https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg&index=2&autoplay=1'); jQuery('#FeaturedVideoIcons div').css('display', 'table-cell'); jQuery(this).hide();">
							<img src="https://img.youtube.com/vi/<?php echo explode('"', $youtube_channel_page_array[2])[0]; ?>/0.jpg" style="width:100%; cursor:pointer;" />
						</div>
						<div style="width:25%; display: table-cell; position:relative; padding:0 1px;" onclick="jQuery('#FeaturedVideoFrame').attr('src', 'https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg&index=3&autoplay=1'); jQuery('#FeaturedVideoIcons div').css('display', 'table-cell'); jQuery(this).hide();">
							<img src="https://img.youtube.com/vi/<?php echo explode('"', $youtube_channel_page_array[3])[0]; ?>/0.jpg" style="width:100%; cursor:pointer;" />
						</div>
						<div style="width:25%; display: table-cell; position:relative; padding:0 1px;" onclick="jQuery('#FeaturedVideoFrame').attr('src', 'https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg&index=4&autoplay=1'); jQuery('#FeaturedVideoIcons div').css('display', 'table-cell'); jQuery(this).hide();">
							<img src="https://img.youtube.com/vi/<?php echo explode('"', $youtube_channel_page_array[4])[0]; ?>/0.jpg" style="width:100%; cursor:pointer;" />
						</div>
						<div style="width:25%; display: table-cell; position:relative; padding:0 1px;" onclick="jQuery('#FeaturedVideoFrame').attr('src', 'https://www.youtube.com/embed?listType=playlist&list=UUMrlVvzRKuvm9mhKgmHT_Tg&index=5&autoplay=1'); jQuery('#FeaturedVideoIcons div').css('display', 'table-cell'); jQuery(this).hide();">
							<img src="https://img.youtube.com/vi/<?php echo explode('"', $youtube_channel_page_array[5])[0]; ?>/0.jpg" style="width:100%; cursor:pointer;" />
						</div>
					</div>
				</div>
			</div>
		</div>
		
		
		<div class="cell large-12" style="text-align:cente; padding:20px 0;">
					<section id="swboc-121" class="widget SWBOC_Widget"><div id="BBSIBNContent04" style="text-align: center;"></div>
</section>				</div>

		
		<div class="cell large-12 grid-x">
			<div class="cell large-12 feed">
				<div class="cell large-12">
					<h2>
						Latest News
					</h2>
				</div>
				<?php
				//get posts by Category each 4 posts and max 4 categories
				//$categories =  get_categories();
			//	foreach($categories as $category){
					//if($category->name != "featured"){
					// EDITED BY PJOHNSON ON 2/19/2019 AS IT APPEARED TO BE EXPECTED THAT ONLY POSTS SHOULD SHOW UP HERE
					$category_posts = new WP_Query(array(
						'post_type' => array('post'),
						'posts_per_page' => 10,
						'orderby' => 'date',
						'order' => 'DESC',
						'suppress_filters' => true,
						'ignore_custom_sort' => true,
						'category__not_in' => array(4, 'Featured')
					));
						if($category_posts->have_posts()){
							$i = 0;
							while($i < 10 && $category_posts->have_posts()){
							$category_posts->the_post();
							
						echo '<div class="cell large-12 post-section">';
							$category_post = get_the_category(get_the_ID());
			echo '<p>';
							if($category_post[0]->name == "Featured"){
							//	echo $category_post[1]->name;
							}else{
							//echo $category_post[0]->name;
							}
							echo '</p>';
							echo '<h3><a href="'.get_post_permalink().'">'.get_the_title().'</a></h3>';										echo '<div class="entry-meta">';
							blue_book_services_posted_on();
							blue_book_services_posted_by();						
							echo '</div><!-- .entry-meta -->';

							echo '</div>';
							$i++;
						}
						echo '<a class="button button-primary" href="/produce-news/page/2">More News</a>';
					}				
				?>
			</div>
			</div>
					</div>
			<div class="cel large-3 small-12 column sidebar">
				<?php 
				//dynamic_sidebar("hp_right_sidebar");
				
				// Home Page Right Sidebar
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
		</main><!-- #main -->
	</div><!-- #primary -->


<?php
//get_sidebar();
get_footer();
?>   
<script src="<?php bloginfo('template_directory'); ?>/js/frontpage.js?v=1.1" type="text/javascript"></script>
