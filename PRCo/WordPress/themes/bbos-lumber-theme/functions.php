<?php
require_once 'inc/Mobile_Detect.php';

function register_extra_sidebars(){
	register_sidebar( array(
		'name'          => esc_html__( 'Homepage Right Sidebar', 'blue-book-services' ),
		'id'            => 'hp-right-sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	) );
	register_sidebar(array(
		'name'          => esc_html__( 'Homepage Left Sidebar', 'blue-book-services' ),
		'id' => 'hp_left_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
	register_sidebar(array(
		'name' => esc_html__( 'Post Page Left Sidebar' ),
		'id' => 'post_left_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
	register_sidebar(array(
		'name' => esc_html__( 'Post Page Right Sidebar' ),
		'id' => 'post_right_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
}

add_action('widgets_init', 'register_extra_sidebars');

//add popular posts functions
function wpb_set_post_views($postID) {
    $count_key = 'wpb_post_views_count';
    $count = get_post_meta($postID, $count_key, true);
    if($count==''){
        $count = 0;
        delete_post_meta($postID, $count_key);
        add_post_meta($postID, $count_key, '0');
    }else{
        $count++;
        update_post_meta($postID, $count_key, $count);
    }
}
//To keep the count accurate, lets get rid of prefetching
remove_action( 'wp_head', 'adjacent_posts_rel_link_wp_head', 10, 0);

function wpb_track_post_views ($post_id) {
    if ( !is_single() ) return;
    if ( empty ( $post_id) ) {
        global $post;
        $post_id = $post->ID;    
    }
    wpb_set_post_views($post_id);
}
add_action( 'wp_head', 'wpb_track_post_views');

function wpb_get_post_views($postID){
    $count_key = 'wpb_post_views_count';
    $count = get_post_meta($postID, $count_key, true);
    if($count==''){
        delete_post_meta($postID, $count_key);
        add_post_meta($postID, $count_key, '0');
        return "0 View";
    }
    return $count.' Views';
}


function popular_posts_shortcode($atts){
$weeksback = 1;
$dabeweek = date("Y-m-d", strtotime("-". $weeksback. " week")); 
$dateArray = explode('-',$dabeweek);
	$popularpost = new WP_Query( 
		array( 
			'posts_per_page' => 5, 
			'meta_key' => 'wpb_post_views_count', 
			'orderby' => 'meta_value_num', 
			'order' => 'DESC' ,
			'date_query' => array(
		'after'=> array(
			'year'  => $dateArray[0],
			'month' => $dateArray[1],
			'day'   => $dateArray[2],
		),
	),
		) );
	$popularpost_html = "";
	while ( $popularpost->have_posts() ) : 
		$popularpost->the_post();
		        $popularpost_html .= '<li><a href="'.get_the_permalink().'">'.get_the_title().'</a> </li>';
	endwhile;

	return sprintf('<ul class="pp-post-secction">%s</ul>', $popularpost_html);
}

add_shortcode('popularposts', 'popular_posts_shortcode');
function newsletter_widget($atts){
	return '
<!-- Begin Robly Signup Form -->
<div id="robly_embed_signup">
  <form action="https://list.robly.com/subscribe/post" method="post" id="robly_embedded_subscribe_form" name="robly_embedded_subscribe_form" class="validate" target="_blank"  novalidate="">
    <input type="hidden" name="a" value="516720a7924648f6af19e38e04c1587d" />

    <input type="hidden" name="sub_lists[]" value="340410" />
    <h2>Sign Up For Free Here</h2>
        <input type="email" value="" name="EMAIL" class="slim_email" id="DATA0" placeholder="email address" required="" style="display:none;" />
        <input type="submit" value="Subscribe" name="subscribe" class="slim_button" />
  </form>
</div>
<!-- End Robly Signup Form -->';
}
add_shortcode('newsletter_form', 'newsletter_widget');
/*
add_action( 'save_post', 'wpse_save_post', 10, 2 );
function wpse_save_post( $post_id, WP_Post $post ) {
    if ( ( defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE ) || !current_user_can( 'edit_post' ) ) {
        return;
    }

    if ( !get_post_meta( $post_id, 'author', true ) ) {
        update_post_meta( $post_id, 'author', 'Company Press Release' );
    }

    if ( !get_post_meta( $post_id, 'associated-companies', true ) ) {
        update_post_meta( $post_id, 'associated-companies', '' );
    }
	if ( !get_post_meta( $post_id, 'author', true ) ) {
		add_post_meta( 0, 'author', 'Company Press Release', true );
	}

	if ( !get_post_meta( $post_id, 'associated-companies', true ) ) {
		add_post_meta( 0, 'associated-companies', '', true );
	}
}
*/
remove_action( 'save_post', 'wpse_save_post');

add_action('admin_init','add_custom_fields');

function add_custom_fields() {

	if ( $_SERVER['SCRIPT_NAME'] == '/wp-admin/post-new.php' ) {
		echo '
		<script>
			setTimeout(function() {
				var isAuthorSet = (jQuery("input[value=author]").length > 0);
				var isAssociatedCompaniesSet = (jQuery("input[value=associated-companies]").length > 0);

				if(!isAuthorSet) {
					jQuery("#metakeyinput").val("author");
					jQuery("#metavalue").val("Company Press Release");
					jQuery("#newmeta-submit").click();
				}
				setTimeout(function() {
					var $author = jQuery("input[value=author]");
					if($author.length > 0) {							
						jQuery.ajax({
							type : "POST",
							dataType : "json",
							url : "/wp-admin/admin-ajax.php",
							data : {
								"action": "fixduplicateauthorcustomfield",
								"metaid": $author.parent().parent().attr("id").replace(/\D/g, "")
							},
							success: function(response) {
								console.log(response);
							},
							error: function(response) {
								console.log(response);
							}
						});
					}
				}, 10000);
				if(!isAssociatedCompaniesSet) {
					setTimeout(function() {
						jQuery("#metakeyinput").val("associated-companies");
						jQuery("#metavalue").val("`");
						jQuery("#newmeta-submit").click();
						
						setTimeout(function() {
							jQuery("input[value=associated-companies]").parent().next().find("textarea").val("");
						}, 10000);
					}, 500);
				}
			}, 1000);
		</script>
		';
	}
}

function fixduplicateauthorcustomfield_ajax()
{
	$value = "5";
	if(isset($_REQUEST["metaid"]))
	{
		$metaid = $_REQUEST["metaid"];
		global $wpdb;
		$value = $wpdb->get_var( $wpdb->prepare("EXEC usp_FixDuplicateAuthorCustomField ".$metaid , $metaid) );
		delete_metadata_by_mid( "post", $value );
	}
	return wp_send_json($value);
}

add_action("wp_ajax_fixduplicateauthorcustomfield", "fixduplicateauthorcustomfield_ajax");
add_action("wp_ajax_nopriv_fixduplicateauthorcustomfield", "fixduplicateauthorcustomfield_ajax");

if ( ! function_exists( 'lumber_entry_footer' ) ) :
	/**
	 * Prints HTML with meta information for the categories, tags and comments.
	 */
	function lumber_entry_footer() {
		// Hide category and tag text for pages.
		if ( 'post' === get_post_type() ) {
			/* translators: used between list items, there is a space after the comma */
			$categories_list = get_the_category_list( esc_html__( ', ', 'blue-book-lumber' ) );
			if ( $categories_list ) {
				/* translators: 1: list of categories. */
// 				printf( '<span class="cat-links">' . esc_html__( 'Posted in %1$s', 'blue-book-services' ) . '</span>', $categories_list ); // WPCS: XSS OK.
			}

			/* translators: used between list items, there is a space after the comma */
			$tags_list = get_the_tag_list( '', esc_html_x( ', ', 'list item separator', 'blue-book-lumber' ) );
			if ( $tags_list ) {
				/* translators: 1: list of tags. */
				printf( '<span class="tags-links">' . esc_html__( 'Tagged %1$s', 'blue-book-lumber' ) . '</span>', $tags_list ); // WPCS: XSS OK.
			}
		}

		if ( ! is_single() && ! post_password_required() && ( comments_open() || get_comments_number() ) ) {
			echo '<span class="comments-link">';
			comments_popup_link(
				sprintf(
					wp_kses(
						/* translators: %s: post title */
						__( 'Leave a Comment<span class="screen-reader-text"> on %s</span>', 'blue-book-lumber' ),
						array(
							'span' => array(
								'class' => array(),
							),
						)
					),
					get_the_title()
				)
			);
			echo '</span>';
		}

		edit_post_link(
			sprintf(
				wp_kses(
					/* translators: %s: Name of current post. Only visible to screen readers */
					__( 'Edit <span class="screen-reader-text">%s</span>', 'blue-book-lumber' ),
					array(
						'span' => array(
							'class' => array(),
						),
					)
				),
				get_the_title()
			),
			'<span class="edit-link">',
			'</span>'
		);
	}
endif;

function GUID()
{
    if (function_exists('com_create_guid') === true)
    {
        return trim(com_create_guid(), '{}');
    }

    return sprintf('%04X%04X-%04X-%04X-%04X-%04X%04X%04X', mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(16384, 20479), mt_rand(32768, 49151), mt_rand(0, 65535), mt_rand(0, 65535), mt_rand(0, 65535));
}

function getBase64EncodedImg($url)
{
	$imagelink = file_get_contents($url); 
  
	// image string data into base64 
	return base64_encode($imagelink);
}
	
function getAdsWidget_function($key, $pageName, $adTypes, $maxCount, $mobileDevice, $webUserID, $industryType, $guid)
{
	$returnStr = "";
/*
	$url = BBSI_APPS.  '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget?key=%27BBSIProduceAds%27&pageName=%27ProduceMarketingSite%27&adTypes=%27PMSHPSQ3%27&maxCount=%273%27&pageRequestID=%27'. $guid. '%27&webUserID=%270%27&mobileDevice=%27false%27&industryType=%27P%27';
	$data = array('key' => "%27". $key. "%27", 'pageName' => "%27". $pageName. "%27", 'adTypes' => "%27". $adTypes. "%27", 'maxCount' => "%27". $maxCount. "%27", 'pageRequestID' => "%27". $guid. "%27", 'webUserID' => "%27". $webUserID. "%27", 'mobileDevice' => "%27". $mobileDevice. "%27", 'industryType' => "%27". $industryType. "%27");
	$url = BBSI_APPS. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget';

	$url = <?php BBSI_APPS. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget';
	$data = array('key' => $key, 'pageName' => $pageName, 'adTypes' => $adTypes, 'maxCount' => $maxCount, 'pageRequestID' => $guid, 'webUserID' => $webUserID, 'mobileDevice' => $mobileDevice, 'industryType' => $industryType);
	
	//print_r($data);

	$options = array(
		'http' => array(
			'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
			'method'  => 'POST',
			'content' => http_build_query($data)
		)
	);
	*/
	$baseURL = BBSI_APPS;
	if($adTypes == "KYCPage1" || $adTypes == "KYCPage2")
	{
		//{key: "'null'", articleID: 37, placement: "'KYCPage1'", pageRequestID: "'cfa64f06-402b-49f9-bfa7-c968671f2369'", webUserID: 0}
		$url = $baseURL. '/BBOSWidgets/WidgetHelper.asmx/GetKYCDAdsWidget?key=%27'. $key. '%27&articleID='. $pageName. '&placement=%27'. $adTypes. '%27&pageRequestID=%27'. $guid. '%27&webUserID=%27'. $webUserID. '%27';
		$data = array();
	}
	else
	{
		$url = $baseURL. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget?key=%27'. $key. '%27&pageName=%27'. $pageName. '%27&adTypes=%27'. $adTypes. '%27&maxCount=%27'. $maxCount. '%27&pageRequestID=%27'. $guid. '%27&webUserID=%27'. $webUserID. '%27&mobileDevice=%27'. $mobileDevice. '%27&industryType=%27'. $industryType. '%27';
		$data = array('key' => "%27". $key. "%27", 'pageName' => "%27". $pageName. "%27", 'adTypes' => "%27". $adTypes. "%27", 'maxCount' => "%27". $maxCount. "%27", 'pageRequestID' => "%27". $guid. "%27", 'webUserID' => "%27". $webUserID. "%27", 'mobileDevice' => "%27". $mobileDevice. "%27", 'industryType' => "%27". $industryType. "%27");
	}

	$options = array(
		'http' => array(
			//'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
			'method'  => 'GET'//,
			//'content' => http_build_query($data)
		)
	);
	//echo $url;
	
	$context  = stream_context_create($options);
	try {
		$result = file_get_contents($url, false, $context);
		
		$pos = strpos($result, 'src=\"') + 6;
		
		if($pos > 6)
		{
			$urlstring = substr($result, $pos);
			$pos = strpos($urlstring, '\"');
			
			if($pos > 0)
			{
				$urlstring = substr($urlstring, 0, $pos);
			}
			
			$originalurl = $urlstring;
			$urlstring = str_replace("&", "%26", str_replace(" ", "%20", str_replace("\\", "/", str_replace("\\\\", "/", $urlstring))));
			
			$urlstring = str_replace("/u0027", "%27", str_replace("/u0026", "%26", $urlstring));
			
			$base64string =  getBase64EncodedImg($urlstring);
			//echo $adTypes. " - ". $urlstring. " - ". $base64string. "<br><br>";
			$result = str_replace($originalurl, "data:image/jpeg;base64, ".$base64string, $result);
		}
		//$p = xml_parser_create();
		//xml_parse_into_struct($p, $result, $vals, $index);
		//xml_parser_free($p);
		// $vals[0]["value"];
		$returnStr = $result;
	}
	catch (Exception $e) {
		//echo "Error: ". $e->getMessage();
	}

	restore_error_handler();
	//if ($result === FALSE) { echo "error"; /* Handle error */ }

	return $returnStr;
}

add_theme_support( 'post-thumbnails',array('page','post')); 

function getAdsWidget_shortcode($parms)
{
	$key = 'BBSIProduceAds';
	$pageName = 'LumberMarketingSite';
	$adTypes = 'IA,IA_180x90';
	$maxCount = "1";
	$mobileDevice = "false";
	$webUserID = "0";
	$industryType = "L";
	
	if(isset($parms))
	{
		if(isset($parms["key"]))
		{
			$key = $parms["key"];
		}
		if(isset($parms["pagename"]))
		{
			$pageName = $parms["pagename"];
		}
		if(isset($parms["adtypes"]))
		{
			$adTypes = $parms["adtypes"];
		}
		if(isset($parms["maxcount"]))
		{
			$maxCount = $parms["maxcount"];
		}
		if(isset($parms["webuserid"]))
		{
			$webUserID = $parms["webuserid"];
		}
		if(isset($parms["industrytype"]))
		{
			$industryType = $parms["industrytype"];
		}
		if(isset($parms["guid"]))
		{
			$guid = $parms["guid"];
		}
		if(isset($parms["postid"]))
		{
			$pageName=$parms["postid"];
		}
	}

	$mobiledetect = new Mobile_Detect;
	$mobileDevice = $mobiledetect->isMobile() ? "true" : "false";
	//echo $guid. "<br >";
	$json = getAdsWidget_function($key, $pageName, $adTypes, $maxCount, $mobileDevice, $webUserID, $industryType, $guid);
	$jsonObj = json_decode($json);
	$html = '<div id="AD_'. str_replace(",", "_", $adTypes). '_'. $maxCount. '" style="display:none;">'. $jsonObj->d. '</div>
		';
	return $html;
}
function getAdsWidget_ajax()
{
	$key = 'BBSIProduceAds';
	$pageName = 'LumberMarketingSite';
	$adTypes = 'IA,IA_180x90';
	$maxCount = "3";
	$mobileDevice = "false";
	$webUserID = "0";
	$industryType = "L";
	$guid = GUID();
	
	if(isset($_REQUEST["key"]))
	{
		$key = $_REQUEST["key"];
	}
	if(isset($_REQUEST["pageName"]))
	{
		$pageName = $_REQUEST["pageName"];
	}
	if(isset($_REQUEST["adTypes"]))
	{
		$adTypes = $_REQUEST["adTypes"];
	}
	if(isset($_REQUEST["maxcount"]))
	{
		$maxCount = $_REQUEST["maxcount"];
	}
	if(isset($_REQUEST["mobiledevice"]))
	{
		$mobileDevice = $_REQUEST["mobiledevice"];
	}
	if(isset($_REQUEST["webuserid"]))
	{
		$webUserID = $_REQUEST["webuserid"];
	}
	if(isset($_REQUEST["industryType"]))
	{
		$industryType = $_REQUEST["industryType"];
	}
	if(isset($_REQUEST["guid"]))
	{
		$guid = $_REQUEST["guid"];
	}
	
	wp_send_json(getAdsWidget_function($key, $pageName, $adTypes, $maxCount, $mobileDevice, $webUserID, $industryType, $guid));
}
add_shortcode('getAdsWidget', 'getAdsWidget_shortcode');
add_action("wp_ajax_getadswidget", "getAdsWidget_ajax");
add_action("wp_ajax_nopriv_getadswidget", "getAdsWidget_ajax");
remove_filter( 'the_content', 'wpautop' );

// CHW  11/28/2022
add_filter( 'xmlrpc_methods', function( $methods ) {
	unset( $methods['pingback.ping'] );
	return $methods;
});

// Pat Johnson 3/18/2023 - Add dismiss button to notices in Admin
function custom_admin_js() {
    echo '<script>
	jQuery(function(){
		setTimeout(function() {
			jQuery( ".notice.is-dismissible" ).each( function() {
				var $el = jQuery( this ),
					$button = jQuery( \'<button type="button" class="notice-dismiss"><span class="screen-reader-text"></span></button>\' );

				if ( $el.find( ".notice-dismiss" ).length ) {
					return;
				}

				// Ensure plain text.
				$button.find( ".screen-reader-text" ).text( "Dismiss this notice." );
				$button.on( "click.wp-dismiss-notice", function( event ) {
					event.preventDefault();
					$el.fadeTo( 100, 0, function() {
						$el.slideUp( 100, function() {
							$el.remove();
						});
					});
				});

				$el.append( $button );
			});			
		}, 1000);
	});
	</script>';
}
add_action('admin_footer', 'custom_admin_js');


function my_acf_update_value( $value, $post_id, $field, $original ) {
	$val = $value;
	
	$valarr = explode(",", $val);
	$valnewarr = array();
	$i = 0;
	
	for($idx = 0; $idx < count($valarr); $idx++)
	{
		$v = trim(preg_replace("/[^0-9]/", "", $valarr[$idx]));
		
		if($v != "" && is_numeric($v))
		{
			$valnewarr[$i] = $v;
			$i++;
		}
	}
	
    return implode(",", $valnewarr);
}
// Apply to all fields.
add_filter('acf/update_value/name=associated-companies', 'my_acf_update_value', 10, 4);

function prefix_filter_canonical_example( $canonical ) {
	if(strpos($canonical, "com/more-news/"))
	{
		$canonical = str_replace("com/more-news/", "com". $_SERVER["REQUEST_URI"], $canonical);
	}
    return strtolower($canonical);
}   
add_filter( 'wpseo_canonical', 'prefix_filter_canonical_example', 20 );

// Prevent WP from adding <p> tags on pages
function disable_wp_auto_p( $content ) {
  if ( is_front_page() ) {
    remove_filter( 'the_content', 'wpautop' );
    remove_filter( 'the_excerpt', 'wpautop' );
  }
  return $content;
}
add_filter( 'the_content', 'disable_wp_auto_p', 0 );


function wp_update_attachment_url_domain ($url, $post_id)
{
	if(!file_exists(str_replace('/', '\\', str_replace('https://qalumber.bluebookservices.com', 'D:\\Applications\\MarketingSites\\Lumber', $url)))) {
		$url = str_ireplace('qalumber.bluebookservices.com', 'www.lumberbluebook.com', $url);
	}

   return $url;
}
add_filter( 'wp_get_attachment_url', 'wp_update_attachment_url_domain', 10, 2 );


