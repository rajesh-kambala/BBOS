<?php get_header(); ?>
<script>var $ = jQuery;</script>
<script type="text/javascript" id="bbsiGetAdsWidget" src="<?php echo BBSI_APPS; ?>/BBOSWidgets/javascript/GetAdsWidget.min.js"></script>
<style>
.addtoany_shortcode {position: absolute !important;}
.wp-post-image {height: 250px;}
</style>
<div class="wrap grid-x">

<div class="top-banner" style="display:none;">
	<!--top area for banner ad-->
	<div id="BBSIBNContent01" ></div>
</div>

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>

	<?php endwhile; endif; ?>

<div class="kyc-news-col left cell large-9 medium-8 small-12" style="float: left;padding-right: 25px; margin-top: 15px;">

	<?php $category = get_the_category(); ?>

	<?php if ( isset($category) && $category != null && $category[0]->cat_name == 'Blueprints' ) { echo '<div class="sidebarText">'.do_shortcode( '[smartblock id=1768]' ).'</div>'; } ?>
	<?php if ( isset($category) && $category != null && $category[0]->cat_name == 'General News' ) { echo '<div class="sidebarText">'.do_shortcode( '[smartblock id=2635]' ).'</div>'; } ?>
	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>

		<article id="post-<?php the_ID(); ?>" class="entry-content">
			
			<div class="grid-x">
				<div class="cell large-6 small-12 medium-6"><h1><?php the_title(); ?></h1></div>
				<div class="cell large-6 small-12 medium-6 text-right"><p class="back-to-kyc" style="margin:0; line-height:2.5;"><a href="/know-your-produce-commodity-index/"> <i class="fa fa-arrow-circle-left" aria-hidden="true"></i> Back to Know Your Commodity</a></p></div>
            </div>
            <div class="clearfix"> </div>
			<div class="kyc-title-link">
				<hr />
			</div>
			
			<h2 class="news-standfirst"><?php echo get_post_meta($post->ID, 'standfirst', true) ?></h2>

			<?php 
				$rightsidebar_post = get_field('right_sidebar');
				$title = htmlentities(get_the_title());
				$body = strip_tags(get_the_content());
				$bodyEncode = htmlentities( $body );
				$currUrl = $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"];	
			 ?>


			<!--Social media buttons-->
			<div class="media-share-container no-print">

				<div class="buttons share-btn-kyc" style="height: 40px;">		
					<a class="print" href="#!"><i class="fa fa-print"></i> Print</a> &nbsp; 
					<a class="email" href="mailto:?subject=<?php echo $title;?>&body=From%20Blue%20Book%20Services:%0D%0A%0D%0A<?php echo $title;?>%0D%0A%0D%0A<?php echo 'http://'.$currUrl; ?>%0D%0A%0D%0A"><i class="fa fa-envelope-o"></i> Email</a>
					&nbsp; <?php echo do_shortcode('[addtoany]'); ?>
				</div>
						<div class="share">
							<?php
							// echo do_shortcode('[sharify]');
							?>

						</div>

			</div>
			<div class="clearfix"> </div>
			<!--End of Social media buttons-->	

			<?php 
			if ( has_post_thumbnail()) : 
				echo '<div style="text-align:center;padding-top:10px;">';
				//the_post_thumbnail();
				$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post->ID ));
				$imageID = get_post_thumbnail_id($post->ID);
				$imagealt = get_post_meta($imageID, '_wp_attachment_image_alt', true);
				$imagetitle = get_the_title( $imageID );
				if($imagealt == "") $imagealt = $imagetitle;
				
				echo '<img src="'. $featured_image_url. '" class="attachment-post-thumbnail size-post-thumbnail wp-post-image" title="'. $imagetitle. '" alt="'. $imagealt. '" style="max-width:100%;">';
				echo '</div>';
			endif;
			?>

			<div>
				
				<?php if(isset($_GET['print']) && $_GET['print']  == 'yes') {
					echo apply_filters('the_content',$post->post_content);  ?>


					<script type="text/javascript">
						jQuery(document).ready(function(){ setTimeout(function() { window.print(); }, 1000);
						 setTimeout(function(){ window.history.back(); },3000);
						});
					</script>

				<?php

				} else {
					$content = str_replace("<p>", "<div>", str_replace("</p>", "</div>", str_replace("<p ", "<div ", str_replace("
", '<div style="width:100%; height: 5px;"></div>', str_replace(">
<", '><', str_replace("
{", '{', str_replace("}
", '}', get_the_content())))))));
					echo "<p>". str_replace('{{KYCAD3}}', '<p><!-- Advertising Section --><br>

					<!-- Code Embed v2.3.2 -->
					<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd3", null, '. $post->ID. ', "KYCPage3");</script>
					<!-- End of Code Embed output -->
					</p>', str_replace('{{KYCAD2}}', '<p><!-- Advertising Section --><br>
					<!-- Code Embed v2.3.2 -->
					<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd2", null, '. $post->ID. ', "KYCPage2");</script>
					<!-- End of Code Embed output -->					
					</p>', str_replace('{{KYCAD1}}', '<p>
					<!-- Code Embed v2.3.2 -->
					<script type="text/javascript">var ad1 = new BBSiGetKYCDAdsWidget("kycd1", null, '. $post->ID. ', "KYCPage1");</script>
					<!-- End of Code Embed output -->
					</p><div id="kycd1" style="text-align: center"></div>', str_replace("
					", "</p><p>", $content)))). "</p>";

					wp_pagenavi( array( 'type' => 'multipart' ) );
				}
				?>

				<?php //wp_link_pages(array('before' => 'Pages: ', 'next_or_number' => 'number')); ?>
				<?php echo "<br/>";?>
				<?php the_tags( 'Tags: ', ', ', ''); ?>
				<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
			</div>
			
			<?php edit_post_link('Edit this entry','','.'); ?>

			<?php $pageLength = count($pages);
					  $url = $_SERVER['REQUEST_URI'];

					  $explodedURI = explode('/', $url);
					  end($explodedURI);
					  prev($explodedURI);
					  $keyTar = current($explodedURI);


					 if ($keyTar == $pageLength || $pageLength == '1') { ?>


			<!--
				<div class="author-blurb">
						<p>This information is for your personal, noncommercial use only.</p>
				</div>
			-->


			<!--	

					<div class="author-blurb">
						<p> <?php // the_cfc_field('KYC Copyright Section', 'kyc_meta_box'); ?> Meta Box</p>
				</div>
			-->
			<?php	 }?>
		</article>

		<?php endwhile; endif; ?>
	</div>
	<div class="sidebar spacer-kyc left cell large-3 medium-4 small-12" style="margin-top: 42px;">

		<?php
		$args = [
			'post_type'      => 'wp_block',
			'posts_per_page' => 1,
			'post_name__in'  => ['know-your-commodity-guide'],
			'fields'         => 'ids'
		];
		$sidebars = get_posts( $args );
	
		// Article Left Side Bar
		reblex_display_block($sidebars[0]);
		?>
	
	</div>
</div>
<script>
jQuery(function() {
	setTimeout(function() {
		jQuery("article script").parent().hide();
	}, 1000);
});
</script>
<?php 
	wp_footer();
	//Added by Mobiloud for fixing inner article links- Please don't remove.

	if ( isset( $_SERVER['HTTP_X_ML_PLATFORM'] ) && ( $_SERVER['HTTP_X_ML_PLATFORM'] === "iOS" || $_SERVER['HTTP_X_ML_PLATFORM'] === "Android" ) || strlen( strstr( $_SERVER['HTTP_USER_AGENT'], "Mobiloud" ) ) > 0 ) {
		echo '<script type="text/javascript">   
		
		jQuery( document ).ready(function() {
			const article=document.getElementsByTagName("article")[0];	
		
			 jQuery("body .entry-content a").each(function()
			 {				
				 var $this = jQuery(this);
				 var $href=$this.attr("href");
				 var $target=$this.attr("target");
					 if($target=="_blank")
					 {
						 $this.attr("onclick", "nativeFunctions.handleLink( \'"+ $href +"\', \'External\', \'internal\')");
						 $this.removeAttr("href");
						 $this.removeAttr("target");
					 }
				 }).delay( 3000 ); 

				 jQuery( "body #kycd1, body #kycd2, body #kycd3, body #kycAds .item" ).on( "click", "a", function(e) {					
					e.preventDefault();					
					var $this = jQuery(this);
				 var $href=$this.attr("href");
				 var $target=$this.attr("target");
				 if($target=="_blank")
				 {
					console.log("Href:"+$href);
					nativeFunctions.handleLink( \'"+ $href +"\', \'External\', \'internal\');
				 }
				 				    
				  });
				
		  });
		</script>';
		}

?>
<?php 



get_footer(); ?>