<?php
/*
Template Name: Local Source - Landing Page
MultiEdit: ValueOfMembership,TopSection,MainContent,Bottom
*/
?>
 <?php get_header(); ?>



	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>

	<div class="wrap entry">
		<h1><?php the_title(); ?></h1>
			<?php the_content(); ?>
	</div>
		<?php endwhile; endif; ?>

<?php //get_sidebar(); ?>

</div>

<?php get_footer(); ?>