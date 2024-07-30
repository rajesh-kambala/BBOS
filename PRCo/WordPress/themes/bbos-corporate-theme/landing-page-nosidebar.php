<?php
/*
Template Name: Landing Page Nosidebar Template
*/
?>
<?php get_header(); ?>

<div class="wrap">

	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal landingpage" id="post-<?php the_ID(); ?>">

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>

			<div class="entry">

				<?php the_content(); ?>

				<?php //wp_link_pages(array('before' => 'Pages: ', 'next_or_number' => 'number')); ?>

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		<?php //comments_template(); ?>

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
