<?php
/*
Template Name: Internal Page Nosidebar Template
*/
?>
<?php get_header(); ?>
<!--link rel='stylesheet' id='foundation-css-css' href='//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/css/foundation.min.css?ver=6.1.1' type='text/css' media='all' /-->
<style>
@media print, screen and (min-width: 40em)
.grid-container {
    padding-right: 0.9375rem;
    padding-left: 0.9375rem;
}
.grid-container {
    max-width: 75rem;
    margin: 0 auto;
}
html {
    -webkit-text-size-adjust: 100%;
	box-sizing: border-box;
	-webkit-font-smoothing: antialiased;
}
*, ::after, ::before {
    box-sizing: inherit;
}
@media print, screen and (min-width: 64em) {
	.grid-x>.large-3 {
		width: 25%;
	}
	.grid-x>.large-6 {
		width: 50%;
	}
	.grid-x>.large-9 {
		width: 75%;
	}
	html {
		box-sizing: none;
	}
}
@media print, screen and (min-width: 40em) {
	.grid-x>.medium-9 {
		width: 75%;
	}
}
@media screen and (max-width: 600px) {
	.grid-x {
		display: block !important;
	}
	.cell {
		width: 100% !important;
		max-width: none !important;
	}
	article {
		padding: 0 !important;
	}
	.entry {
		max-width: none !important;
		width: 100% !important;
	}
	.int-sidebar {
		width: 100% !important;
		max-width: none !important;
	}
	article img {
		width: 100% !important;
		max-width: none !important;
	}
	#robly_embed_signup .slim_button {
		max-width: none !important;
	}
	#swboc-13 .button {
		max-width: none !important;
	}
}
@media print, screen and (min-width: 64em) {
	.grid-x>.large-1, .grid-x>.large-10, .grid-x>.large-11, .grid-x>.large-12, .grid-x>.large-2, .grid-x>.large-3, .grid-x>.large-4, .grid-x>.large-5, .grid-x>.large-6, .grid-x>.large-7, .grid-x>.large-8, .grid-x>.large-9, .grid-x>.large-full, .grid-x>.large-shrink {
		flex-basis: auto;
	}
}
@media print, screen and (min-width: 40em) {
	.grid-x>.medium-1, .grid-x>.medium-10, .grid-x>.medium-11, .grid-x>.medium-12, .grid-x>.medium-2, .grid-x>.medium-3, .grid-x>.medium-4, .grid-x>.medium-5, .grid-x>.medium-6, .grid-x>.medium-7, .grid-x>.medium-8, .grid-x>.medium-9, .grid-x>.medium-full, .grid-x>.medium-shrink {
		flex-basis: auto;
	}
}
.cell {
    -webkit-box-flex: 0;
    -webkit-flex: 0 0 auto;
    -ms-flex: 0 0 auto;
    flex: 0 0 auto;
    min-height: 0;
    min-width: 0;
    width: 100%;
}
main {
    display: block;
}
article, aside, footer, header, nav, section {
    display: block;
}
.grid-x .sidebar {
	padding: 0 10px;
}
#primary {
	padding: 0;
}
.wp-block-image, .wp-block-image .alignleft {
    margin: 0 auto !important;
	float: none;
}
header {
    margin-bottom: 30px;
}
.int-sidebar {
	flex-basis: auto;
	width: 25%;
	max-width: 280px;
}
.entry {
	width: 75%;
	flex-basis:auto;
	max-width: 855px;
}
#robly_embed_signup .slim_button {
	max-width: 260px;
}
#swboc-13 .button {
	max-width: 240px;
}
.grid-x .newsletter {
	width: 67%;
	max-width: 535px;
}
.grid-x .newsletter img {
	display: inline-block;
}
</style>
<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal landingpage grid-x" id="post-<?php the_ID(); ?>">

			<h2><?php the_title(); ?></h2>

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">

				<?php the_content(); ?>

				<?php //wp_link_pages(array('before' => 'Pages: ', 'next_or_number' => 'number')); ?>

			</div>
			<?php 
			$rightsidebar_post = get_field('right_sidebar');
			$content = (($rightsidebar_post != null)? $rightsidebar_post->post_content : "");
			
			if($content != "")
			{
				echo '<div class="int-sidebar right">';
				$blocks = parse_blocks( $content );
				foreach( $blocks as $block ) {
					//if( 'core/quote' === $block['blockName'] ) {
					echo do_shortcode(render_block( $block ));
					//break;
					//}
				}
				echo '</div>';
			}
			?>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>
<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
