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


/*
Template Name: Company Profile Page Template
*/

 get_header(); ?>
<link rel="stylesheet" media="screen"  href="<?php bloginfo('template_directory'); ?>/css/companyprofile.css?v=1.2">

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
				<div class="cat-sidebar2 sidebar mar_top_7 mar_bot_25 col-sm-4 col-xs-12">
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
											<a href="#" onclick="openWindow(\'https://apps.bluebookservices.com/BBOS/ExternalLink.aspx?BBOSURL=https%3a%2f%2fwww.linkedin.com%2fcompany%2fmagliocompanies&amp;BBOSID='. $_REQUEST["id"]. '&amp;BBOSType=C&amp;TriggerPage=/ProducePublicProfiles/CompanyProfile.aspx\')"><img alt="LinkedIn Company Page" border="0" data-src="/ProducePublicProfiles/Images/linkedin.png" class=" lazyloaded" src="/ProducePublicProfiles/Images/linkedin.png"><noscript><img src="/ProducePublicProfiles/Images/linkedin.png" alt="LinkedIn Company Page" border="0" /></noscript></a></td>
								</tr>
								';
								*/
								if($rows[0]->comp_PRListingStatus = "L" || $rows[0]->comp_PRListingStatus = "H" || $rows[0]->comp_PRListingStatus = "LUV")
								{
									$commoditieshandled = "";
									$supplychainclassifications = "";
									
									$rws = $wpdb->get_results( "EXEC usp_GetCompanyCommodityAttributeByCompanyID ". $_REQUEST["id"] );
									if(count($rws) > 0) $commoditieshandled = $rws[0]->commoditycount. " commodities handled. ";
									
									$rws = $wpdb->get_results( "EXEC usp_GetCompanyClassificationByCompanyID ". $_REQUEST["id"] );
									if(count($rws) > 0) $supplychainclassifications = $rws[0]->classificationcount. " supply chain classifications. ";
									
									echo '<tr id="BBOSPublicProfilesMain_trListingInfo">
										<td colspan="2" style="text-align: left; padding-top: 15px;">
											This company is Blue Book Services rated. (Blue Book Ratings include one or more of the following: pay description, moral responsibility indicator and credit worth estimate.)

											<p>
												'. $commoditieshandled. $supplychainclassifications. ' 
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
				
				$content_post = get_post(328);
				echo $content_post->post_content;
				
			echo '
			</div>
			';

			edit_post_link('Edit this entry.', '<p>', '</p>');

			echo '
		</article>
		<div class="cell large-3 small-12 medium-4 column sidebar" style="z-index:1000;">
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
<?php
if(isset($_REQUEST["id"]))
{
	echo '<script>
	jQuery("#BBOSPublicProfilesMain_hlGetBR").attr("href", "/Payment/?c='. $_REQUEST["id"]. '");
	</script>
	';
}

 get_footer();

echo '<script src="';
bloginfo('template_directory');
echo '/js/companyprofile.js?v=1.3" type="text/javascript"></script>';
?>
<script>
var licenseKey = "BBSIProduceAds";
var pageName = "ProduceMarketingSite";
var ad1 = new BBSiGetAdsWidget("BBSISQContent01", licenseKey, pageName, 1, "PMSHPSQ");
var ad2 = new BBSiGetAdsWidget("BBSIBNContent01", licenseKey, pageName, 1, "PMSHPB");
var ad3 = new BBSiGetAdsWidget("BBSIBNContent02", licenseKey, pageName, 1, "PMSHPB2");
var ad4 = new BBSiGetAdsWidget("BBSISQContent03", licenseKey, pageName, 1, "PMSHPSQ2");
var ad5 = new BBSiGetAdsWidget("BBSISQContent04", licenseKey, pageName, 1, "PMSHPSQ3");
var ad6 = new BBSiGetAdsWidget("BBSIBNContent03", licenseKey, pageName, 1, "PMSHPB2");
var ad7 = new BBSiGetAdsWidget("BBSIBNContent04", licenseKey, pageName, 1, "PMSHPB3");
var ad8 = new BBSiGetAdsWidget("BBSIOAContent01", licenseKey, pageName, 3, "IA,IA_180x90");
var ad9 = new BBSiGetAdsWidget("BBSIOAContent02", licenseKey, pageName, 4, "IA,IA_180x90");
</script>




