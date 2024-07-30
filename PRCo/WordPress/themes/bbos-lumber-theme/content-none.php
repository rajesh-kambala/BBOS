<?php
/**
 * Template part for displaying a message that posts cannot be found
 *
 * @link https://developer.wordpress.org/themes/basics/template-hierarchy/
 *
 * @package Blue_Book_Services
 */

?>
<style>
h2 {
	margin-top: 0;
    margin-bottom: .5rem;
    text-rendering: optimizeLegibility;
	clear: both;
	margin-bottom: 20px;
}
#main {
	min-height: 500px;
    height: 100%;
    float: left;
}
.col_center {
	height: 100%;
    width: 100%;
}
article {
	height:100%;
	min-height: 450px;
}
</style>
<section class="no-results not-found">
	<div class="page-header">
		<h2 class="page-title"><?php esc_html_e( 'Nothing Found', 'blue-book-services' ); ?></h2>
	</div><!-- .page-header -->

	<div class="page-content">
		<?php
		if ( is_home() && current_user_can( 'publish_posts' ) ) :

			printf(
				'<p>' . wp_kses(
					/* translators: 1: link to WP admin new post page. */
					__( 'Ready to publish your first post? <a href="%1$s">Get started here</a>.', 'blue-book-services' ),
					array(
						'a' => array(
							'href' => array(),
						),
					)
				) . '</p>',
				esc_url( admin_url( 'post-new.php' ) )
			);

		elseif ( is_search() ) :
			?>

			<p><?php esc_html_e( 'Sorry, but nothing matched your search terms. Please try again with some different keywords.', 'blue-book-services' ); ?></p>
			<?php
			get_search_form();

		else :
			?>

			<p><?php esc_html_e( 'It seems we can&rsquo;t find what you&rsquo;re looking for. Perhaps searching can help.', 'blue-book-services' ); ?></p>
			<?php
			get_search_form();

		endif;
		?>
		<br />
		<br />
	<form role="search" method="get" class="search-form" action="/">
				<label>
					<input type="search" class="search-field" placeholder="Search …" value="<?php echo $_GET['s']; ?>" name="s" style="display: block; 
    -webkit-box-sizing: border-box;box-sizing: border-box;width: 100%;height: 2.4375rem; margin: 0 0 1rem; padding: .5rem;border: 1px solid #cacaca;border-radius: 0;background-color: #fefefe;-webkit-box-shadow: inset 0 1px 2px rgba(10,10,10,.1);box-shadow: inset 0 1px 2px rgba(10,10,10,.1);font-family: inherit;font-size: 1rem;font-weight: 400;line-height: 1.5;color: #0a0a0a;-webkit-transition: border-color .25s ease-in-out,-webkit-box-shadow .5s;transition: border-color .25s ease-in-out,-webkit-box-shadow .5s;transition: box-shadow .5s,border-color .25s ease-in-out;transition: box-shadow .5s,border-color .25s ease-in-out,-webkit-box-shadow .5s;-webkit-appearance: none;">
				</label>
				<input type="submit" class="search-submit" value="Search" style="padding: 10px!important; font-size: 1rem!important; min-width: 100px;
    border: none!important; background: #333!important; color: #FFF!important;">
			</form>
	</div><!-- .page-content -->
</section><!-- .no-results -->
