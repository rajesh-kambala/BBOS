<?php
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);

/**
 * Template part for displaying results in search pages
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

?>

<article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
	<div>
		<?php 
		the_title( sprintf( '<h3><a href="%s" rel="bookmark">', esc_url( get_permalink() ) ), '</a></h3>' );
		$ID = get_the_ID();
		$postdate = date_create($post->post_date);

		echo '<div class="entry-meta">';
		echo '<span class="published_date">'.date_format($postdate,"F j, Y").',</span>';
		$category_post = get_the_category(get_the_ID());
		if(count($category_post) > 0)
		{
			echo '<span class="published_category"> '. $category_post[0]->cat_name. '</span>';
		}
		$author = get_post_meta($ID, 'custom_author', true);
		if($author){
				echo '<span class="post-author">, '. $author .'</span>';
		}
		else {
			$author = get_post_meta($ID, 'author', true);
			if($author){
				echo '<span class="post-author">, '. $author .'</span>';
			}
		}
		echo '</div><!-- .entry-meta -->';
		?>
	</div><!-- .entry-header -->

	<?php
	?>

		<?php 
		//the_excerpt(); 
		?>
	
		<?php
		//entry_footer(); 
		?>
</article><!-- #post-<?php the_ID(); ?> -->
