<?php
/*
Template Name: Company Directory Page Template
*/
get_header();
?>
<div class="wrap">




	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
		<article class="internal" id="post-<?php the_ID(); ?>">
			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
			<div class="entry">
		<?php
		//while ( have_posts() ) :
//
		if(!isset($_REQUEST["begin"]))
		{
			get_template_part( 'template-parts/content', 'page' );
		}
		else
		{
			echo '<p>The purpose of this page is to provide all listed companies in the Blue Book Services database extra exposure and branding via search engines. If you have come to this page for a specific company or a list of companies and you are a Blue Book Member, please <a href="https://apps.bluebookservices.com/BBOS/Login.aspx">sign into Blue Book Online Services</a> (BBOS) for more comprehensive information and search capabilities.</p>';
			global $wpdb;
			$rows = $wpdb->get_results( "EXEC usp_CompanySearchByFirstLetter '". $_REQUEST["begin"]. "'" );
			echo '<div><ul style="list-style-type: none;">';
			for($idx = 0; $idx < count($rows); $idx++)
			{
				echo '<li style="float:left; width:30%;"><a href="'. $rows[$idx]->prce_WordPressSlug. '">'. $rows[$idx]->comp_PRCorrTradestyle. '</a></li>';
			}
			echo '</ul>
			</div>
			<p style="clear:both;">For those seeking more information about Blue Book membership, please contact us. Our representatives will be happy to help determine how a Blue Book Services membership can best be used to expand and support any business.</p>
			';
		}

		//endwhile; // End of the loop.
		?>

					<!--iframe sandbox="allow-same-origin allow-top-navigation allow-forms allow-scripts" 
					        height="600px" width="1000px" seamless style="overflow: hidden;" scrolling="no" 
							src="//<?php echo $_SERVER['SERVER_NAME']; ?>/ProducePublicProfiles/Default.aspx">
					</iframe-->  

			</div>

			<?php edit_post_link('Edit this entry.', '<p>', '</p>'); ?>

		</article>
		
		

		<?php endwhile; endif; ?>

<div class="clearfix"></div>

</div>

<?php get_footer(); ?>
