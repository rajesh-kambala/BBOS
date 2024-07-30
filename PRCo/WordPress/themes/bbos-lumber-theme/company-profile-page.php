<?php
if(isset($_REQUEST["ID"]))
{
	global $wpdb;
	$rows = $wpdb->get_results( "EXEC usp_CompanySearchByID ". $_REQUEST["ID"]);
	if(count($rows) > 0)
	{
		//echo $_SERVER['SERVER_NAME']. $rows[0]->prce_WordPressSlug;
		header("Location: ". $rows[0]->prce_WordPressSlug, true, 301);
		exit;
	}
}

echo '<script type="text/javascript" id="bbsiGetAdsWidget" src="'. BBSI_APPS. '/BBOSWidgets/javascript/GetAdsWidget.min.js"></script>';
echo '<script src="';
bloginfo('template_directory');
echo '/js/companyprofile.js?v=1.3" type="text/javascript"></script>';
/*
Template Name: Company Profile Page Template
*/

 get_header(); ?>
<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/companyprofile.css?v=1.2">

<div class="wrap" style="display:none;">


<script type="text/javascript">
  jQuery(document).ready(function($){
	jQuery("footer, .wrap").show();
  });
</script>  


	<?php if (have_posts()) : while (have_posts()) : the_post(); ?>
			
				
			<div class="grid-x grid-container">
				
		<article class="internal landingpage" id="post-<?php the_ID(); ?>" style="width:900px;">

			<?php //include (TEMPLATEPATH . '/_/inc/meta.php' ); ?>
			<div class="row">
				<div class="cat-sidebar2 sidebar mar_top_7 mar_bot_25 col-sm-4 col-xs-12" style="padding: 20px; border: 1px solid rgba(0, 0, 0, 0.1); width:280px; margin-right: 20px;">
					<div id="BBSISQContent03"></div>
					<h2>Company Profile</h2>
					<?php 
					global $wpdb;
					$rows = $wpdb->get_results( "EXEC usp_GetCompanyByID ". $_REQUEST["id"] );
					if(count($rows) > 0)
					{
						echo '<table id="BBOSPublicProfilesMain_tblListing" class="smalltable">
						<tbody><tr>
							<td colspan="2" class="listing">
								BB #' . $rows[0]->comp_CompanyID. '
								<br/>
								'. $rows[0]->comp_PRCorrTradestyle. '<br />
								';
								
								if($rows[0]->comp_PRLegalName <> "")
								{
									echo 'Legal Name: '. $rows[0]->comp_PRLegalName. '<br />
									';
								}
								echo $rows[0]->CityStateCountryShort. '
									</td>
								</tr>
								<tr>
									<td class="column1">Industry:</td>
									<td>
													'. $rows[0]->IndustryType. '</td>
								</tr>
								<tr>
									<td class="column1">Type:</td>
									<td>
													'. $rows[0]->PRType. '</td>
								</tr>
								<tr>
									<td class="column1">Phone:</td>
									<td>
													'. $rows[0]->Phone. '</td>
								</tr>
								<tr>
									<td class="column1">Fax:</td>
									<td>
													'. $rows[0]->Fax. '</td>
								</tr>
								<tr>
									<td class="column1">Toll Free:</td>
									<td>
													'. $rows[0]->TollFree. '</td>
								</tr>
								<tr id="BBOSPublicProfilesMain_trSocialMedia">
										<td class="column1">Social Media:</td>
										<td>
										';
										$sbSocialMedia = "";
										$rws = $wpdb->get_results( "EXEC usp_GetSocialMediaByCompanyID ". $_REQUEST["id"] );
										for($idx = 0; $idx < count($rws); $idx++)
										{
											$sbSocialMedia .= '<a href="#" onclick="window.open(\'https://apps.bluebookservices.com/BBOS/ExternalLink.aspx?BBOSURL='. urlencode($rws[$idx]->prsm_URL). '&amp;BBOSID='. $_REQUEST["id"]. '&amp;BBOSType=C&amp;TriggerPage=/ProducePublicProfiles/CompanyProfile.aspx\', \'_blank\')"><img data-src="https://www.producebluebook.com/ProducePublicProfiles/Images/'. $rws[$idx]->prsm_SocialMediaTypeCode. '.png" class=" lazyloaded" src="https://www.producebluebook.com/ProducePublicProfiles/Images/'. $rws[$idx]->prsm_SocialMediaTypeCode. '.png" alt="'. $rws[$idx]->SocialMediaType. '" border="0" /><noscript><img src="https://www.producebluebook.com/ProducePublicProfiles/Images/'. $rws[$idx]->prsm_SocialMediaTypeCode. '.png" alt="'. $rws[$idx]->SocialMediaType. '" border="0" /></noscript></a>';
										}
										echo $sbSocialMedia. '
										</td></tr>';
										/*
								echo '
											<a href="#" onclick="openWindow(\'https://apps.bluebookservices.com/BBOS/ExternalLink.aspx?BBOSURL=https%3a%2f%2fwww.linkedin.com%2fcompany%2fmagliocompanies&amp;BBOSID=105281&amp;BBOSType=C&amp;TriggerPage=/ProducePublicProfiles/CompanyProfile.aspx\')"><img alt="LinkedIn Company Page" border="0" data-src="/ProducePublicProfiles/Images/linkedin.png" class=" lazyloaded" src="/ProducePublicProfiles/Images/linkedin.png"><noscript><img src="/ProducePublicProfiles/Images/linkedin.png" alt="LinkedIn Company Page" border="0" /></noscript></a></td>
								</tr>
								';
								*/
								if($rows[0]->comp_PRListingStatus = "L" || $rows[0]->comp_PRListingStatus = "H" || $rows[0]->comp_PRListingStatus = "LUV")
								{
									$specieshandled = "";
									//$commoditieshandled = "";
									$supplychainclassifications = "";
									
									//$rws = $wpdb->get_results( "EXEC usp_GetCompanyCommodityAttributeByCompanyID ". $_REQUEST["id"] );
									//if(count($rws) > 0) $commoditieshandled = $rws[0]->commoditycount. " commodities handled. ";
									//echo "EXEC usp_GetCompanySpeciesByCompanyID ". $_REQUEST["id"];
									$rws = $wpdb->get_results( "EXEC usp_GetCompanySpeciesByCompanyID ". $_REQUEST["id"] );
									if(count($rws) > 0) $specieshandled = $rws[0]->speciescount. " species handled. ";
									
									$rws = $wpdb->get_results( "EXEC usp_GetCompanyClassificationByCompanyID ". $_REQUEST["id"] );
									if(count($rws) > 0) $supplychainclassifications = $rws[0]->classificationcount. " supply chain classifications. ";
									
									echo '<tr id="BBOSPublicProfilesMain_trListingInfo">
										<td colspan="2" style="text-align: left; padding-top: 15px;">
											This company is Blue Book Services rated. (Blue Book Ratings include one or more of the following: pay description, moral responsibility indicator and credit worth estimate.)

											<p>
												'. $specieshandled. $supplychainclassifications. ' 
												Full listings are available to Blue Book members and can include contact names, emails, websites, brand names, specialties, and more.
												
											</p>
										</td>
									</tr>
									';
								}
					}
								echo '
					</tbody></table>
					<div id="MostReadDIV">';

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

					  echo '
					</div>
				</div>';
				
				the_content();
				
			echo '
			</div>
			';

			edit_post_link('Edit this entry.', '<p>', '</p>');

			echo '
		</article>
		<div class="cell large-3 small-12 medium-4 column sidebar" style="width: 290px; float: left; padding: 20px; border: 1px solid rgba(0, 0, 0, 0.1);">
';

		//get_sidebar(); 

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
	</div>
		

		<?php endwhile; endif; ?>


	
<div class="clearfix"></div>

</div>
<?php get_footer();






