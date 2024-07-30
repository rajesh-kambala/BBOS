<?php
/**
 * Blue Book Services functions and definitions
 *
 * @link https://developer.wordpress.org/themes/basics/theme-functions/
 *
 * @package Blue_Book_Services
 */
require_once 'inc/Mobile_Detect.php';
@ini_set( 'upload_max_size' , '128M' );
@ini_set( 'post_max_size', '128M');
@ini_set( 'max_execution_time', '300' );

if ( ! function_exists( 'blue_book_services_setup' ) ) :
	/**
	 * Sets up theme defaults and registers support for various WordPress features.
	 *
	 * Note that this function is hooked into the after_setup_theme hook, which
	 * runs before the init hook. The init hook is too late for some features, such
	 * as indicating support for post thumbnails.
	 */
	function blue_book_services_setup() {
		/*
		 * Make theme available for translation.
		 * Translations can be filed in the /languages/ directory.
		 * If you're building a theme based on Blue Book Services, use a find and replace
		 * to change 'blue-book-services' to the name of your theme in all the template files.
		 */
		load_theme_textdomain( 'blue-book-services', get_template_directory() . '/languages' );

		// Add default posts and comments RSS feed links to head.
		add_theme_support( 'automatic-feed-links' );

		/*
		 * Let WordPress manage the document title.
		 * By adding theme support, we declare that this theme does not use a
		 * hard-coded <title> tag in the document head, and expect WordPress to
		 * provide it for us.
		 */
		add_theme_support( 'title-tag' );

		/*
		 * Enable support for Post Thumbnails on posts and pages.
		 *
		 * @link https://developer.wordpress.org/themes/functionality/featured-images-post-thumbnails/
		 */
		add_theme_support( 'post-thumbnails' );

		// This theme uses wp_nav_menu() in one location.
		register_nav_menus( array(
			'menu-1' => esc_html__( 'Primary', 'blue-book-services' ),
			'mega-menu' => esc_html__( 'Mega Menu', 'blue-book-services' ),
			'footer-menu' => esc_html__('Footer Links', 'blue-book-services'),
		    'social-menu' => esc_html__('Social Links', 'blue-book-services'),
		) );

		/*
		 * Switch default core markup for search form, comment form, and comments
		 * to output valid HTML5.
		 */
		add_theme_support( 'html5', array(
			'search-form',
			'comment-form',
			'comment-list',
			'gallery',
			'caption',
		) );

		// Set up the WordPress core custom background feature.
		add_theme_support( 'custom-background', apply_filters( 'blue_book_services_custom_background_args', array(
			'default-color' => 'ffffff',
			'default-image' => '',
		) ) );

		// Add theme support for selective refresh for widgets.
		add_theme_support( 'customize-selective-refresh-widgets' );

		/**
		 * Add support for core custom logo.
		 *
		 * @link https://codex.wordpress.org/Theme_Logo
		 */
		add_theme_support( 'custom-logo', array(
			'height'      => 200,
			'width'       => 500,
			'flex-width'  => true,
			'flex-height' => true,
		) );
	}
endif;
add_action( 'after_setup_theme', 'blue_book_services_setup' );

/**
 * Set the content width in pixels, based on the theme's design and stylesheet.
 *
 * Priority 0 to make it available to lower priority callbacks.
 *
 * @global int $content_width
 */
function blue_book_services_content_width() {
	// This variable is intended to be overruled from themes.
	// Open WPCS issue: {@link https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards/issues/1043}.
	// phpcs:ignore WordPress.NamingConventions.PrefixAllGlobals.NonPrefixedVariableFound
	$GLOBALS['content_width'] = apply_filters( 'blue_book_services_content_width', 640 );
}
add_action( 'after_setup_theme', 'blue_book_services_content_width', 0 );

/**
 * Register widget area.
 *
 * @link https://developer.wordpress.org/themes/functionality/sidebars/#registering-a-sidebar
 */
function blue_book_services_widgets_init() {
	register_sidebar( array(
		'name'          => esc_html__( 'Homepage Right Sidebar', 'blue-book-services' ),
		'id'            => 'hp_right_sidebar',
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
		'name'          => esc_html__( 'Post Left Sidebar', 'blue-book-services' ),
		'id' => 'post_left_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
		register_sidebar(array(
		'name'          => esc_html__( 'Post Right Sidebar', 'blue-book-services' ),
		'id' => 'post_right_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
		register_sidebar(array(
		'name'          => esc_html__( 'Page Sidebar', 'blue-book-services' ),
		'id' => 'page_sidebar',
		'description'   => esc_html__( 'Add widgets here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));
		register_sidebar(array(
		'name'          => esc_html__( 'Homepage Large Banner Ad', 'blue-book-services' ),
		'id' => 'ad_sidebar',
		'description'   => esc_html__( 'Add Ad here.', 'blue-book-services' ),
		'before_widget' => '<section id="%1$s" class="widget %2$s">',
		'after_widget'  => '</section>',
		'before_title'  => '<h2 class="widget-title">',
		'after_title'   => '</h2>',
	));

}
add_action( 'widgets_init', 'blue_book_services_widgets_init' );

/**
 * Enqueue scripts and styles.
 */
function blue_book_services_scripts() {
	wp_enqueue_style( 'blue-book-services-style', get_stylesheet_uri(), [], "4.9.9.5.5" );

	wp_enqueue_script( 'blue-book-services-navigation', get_template_directory_uri() . '/js/navigation.js', array(), '20151215', true );

	wp_enqueue_script( 'blue-book-services-skip-link-focus-fix', get_template_directory_uri() . '/js/skip-link-focus-fix.js', array(), '20151215', true );
	
	/*Foundation CDN Files*/
	wp_enqueue_style('foundation-css', '//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/css/foundation.min.css');
	wp_enqueue_script('foundation-js', '//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/foundation.min.js', array('jquery'));
	wp_enqueue_script('foundation-motionui', '//cdnjs.cloudflare.com/ajax/libs/foundation/6.4.3/js/plugins/foundation.util.motion.min.js', array('jquery', 'foundation-js'));
	/*Foundation CDN Files*/
	
	//font awesome cdn
	wp_enqueue_style('font-awesome', '//cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css');
	if ( is_singular() && comments_open() && get_option( 'thread_comments' ) ) {
		wp_enqueue_script( 'comment-reply' );
	}
}
add_action( 'wp_enqueue_scripts', 'blue_book_services_scripts' );

/**
 * Implement the Custom Header feature.
 */
require get_template_directory() . '/inc/custom-header.php';

/**
 * Custom template tags for this theme.
 */
require get_template_directory() . '/inc/template-tags.php';

/**
 * Functions which enhance the theme by hooking into WordPress.
 */
require get_template_directory() . '/inc/template-functions.php';

/**
 * Customizer additions.
 */
require get_template_directory() . '/inc/customizer.php';

/**
 * Load Jetpack compatibility file.
 */
if ( defined( 'JETPACK__VERSION' ) ) {
	require get_template_directory() . '/inc/jetpack.php';
}
function the_excerpt_length($length){
	return 16;
}
add_filter('excerpt_length', 'the_excerpt_length', 999);

//external - add settings for featured sections to add ability to choose articles to display

add_action('customize_register', 'pin_articles_settings');

function pin_articles_settings($wp_customize){
			/*add settings editable by user using customizer*/

			 $wp_customize->add_section('pin_articles_options', array(
		        'title' => __("Pin Articles", 'pin_articles_options'),
		        'priority' => 30
		    ));
    
   			 //add setting
    
		    //add control
		    //get all posts
		    $get_posts = get_posts(array('posts_per_page'=>-1));
		    $posts_array = array();
		    foreach ($get_posts as $post_value) {
		    	# code...
		    	$posts_array[$post_value->ID] = $post_value->post_title;
		    }
			$author_array_cp = get_posts(array('post_type'=> 'cp_post_authors', 'posts_per_page'=>-1));
			$author_array = array();
			foreach($author_array_cp as $cp_author){
				$author_array[$cp_author->ID] = $cp_author->post_title;
			}
		    $wp_customize->add_setting('pin_articles_options_setting_1', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		    $wp_customize->add_setting('pin_articles_options_author_1', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		    
		    $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_setting_1', array(
		        'type' => 'select',
		        'label' => __('Choose Article for Section 1', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_setting_1',
		        'section' => 'pin_articles_options',
		        'choices' => $posts_array
		    )));
		    
      $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_author_1', array(
		        'type' => 'select',
		        'label' => __('Choose Author for Section 1', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_author_1',
		        'section' => 'pin_articles_options',
		        'choices' => $author_array
		    )));
		    
    
	  $wp_customize->add_setting('pin_articles_options_author_2', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		  
	  $wp_customize->add_setting('pin_articles_options_setting_2', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		    
		    $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_setting_2', array(
		        'type' => 'select',
		        'label' => __('Choose Article for Section 2', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_setting_2',
		        'section' => 'pin_articles_options',
		        'choices' => $posts_array
		    )));
	
	  $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_author_2', array(
		        'type' => 'select',
		        'label' => __('Choose Author for Section 2', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_author_2',
		        'section' => 'pin_articles_options',
		        'choices' => $author_array
		    )));
		    
    
	  $wp_customize->add_setting('pin_articles_options_author_3', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		  
		    
      $wp_customize->add_setting('pin_articles_options_setting_3', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		    
		    $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_setting_3', array(
		        'type' => 'select',
		        'label' => __('Choose Article for Section 3', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_setting_3',
		        'section' => 'pin_articles_options',
		        'choices' => $posts_array
		    )));
		      $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_author_3', array(
		        'type' => 'select',
		        'label' => __('Choose Author for Section 3', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_author_3',
		        'section' => 'pin_articles_options',
		        'choices' => $author_array
		    )));
		    
    
	  $wp_customize->add_setting('pin_articles_options_author_4', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		  
      $wp_customize->add_setting('pin_articles_options_setting_4', array(
		        'type' => 'option',
		        'default' => '',
		        'transport' => 'refresh'
		    ));
		    
		    $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_options_setting_4', array(
		        'type' => 'select',
		        'label' => __('Choose Article for Section 4', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_setting_4',
		        'section' => 'pin_articles_options',
		        'choices' => $posts_array
		    )));
	

		    $wp_customize->add_control(new WP_Customize_Control($wp_customize, 'pin_articles_author_setting_4', array(
		        'type' => 'select',
		        'label' => __('Choose Author for Section 4', 'pin_articles_options'),
		        'settings' => 'pin_articles_options_author_4',
		        'section' => 'pin_articles_options',
		        'choices' => $author_array
		    )));
	
}


//add login shortcode

function login_form($atts, $content){
	$a = shortcode_atts(array(
		'id' => 'login_form'
	), $atts);
	if(get_current_user_id()){
		echo 'You are already logged In';
	}else{
	return '<form name="loginform" id="loginform" action="'.get_site_url().'/wp-login.php" method="post">
	<p>
		<label for="user_login">Username or Email Address<br>
		<input type="text" name="log" id="user_login" class="input" value="" size="20"></label>
	</p>
	<p>
		<label for="user_pass">Password<br>
		<input type="password" name="pwd" id="user_pass" class="input" value="" size="20"></label>
	</p>
		<p class="forgetmenot"><label for="rememberme"><input name="rememberme" type="checkbox" id="rememberme" value="forever"> Remember Me</label></p>
	<p>
		<input type="submit" name="wp-submit" id="wp-submit" class="button button-primary button-large" value="Log In">
		<input type="hidden" name="redirect_to" value="'.get_site_url().'">
		<input type="hidden" name="testcookie" value="1">
	</p>
</form>';
	}
}

add_shortcode('login_form', 'login_form');

//add newsletter shortcode using code

function newsletter_widget($atts){
	return '
<script src="https://www.google.com/recaptcha/api.js?render=explicit" async defer></script>
<!-- Begin Robly Signup Form -->
<div id="robly_embed_signup">
  <form action="https://list.robly.com/subscribe/post" method="post" id="robly_embedded_subscribe_form" name="robly_embedded_subscribe_form" class="validate" target="_blank"  novalidate="">
    <input type="hidden" name="a" value="516720a7924648f6af19e38e04c1587d" />
    <input type="hidden" name="sub_lists[]" value="329573" />
    <h2>Sign Up for a Free, Daily Produce Newsletter</h2>
	<p>Stay in the know and elevate your produce industry expertise! Sign up now for our exclusive Produce Newsletter and receive the latest news, trends, and analyses directly to your inbox. Don\'t miss out on vital updates that can transform your business. Join our community today and reap the benefits of timely, insightful information. Subscribe today to cultivate your success in the ever-growing world of fresh produce!</p>
        <input type="email" value="" name="EMAIL" class="slim_email" id="DATA0" placeholder="email address" required="" style="display:none;"/>
        <input type="submit" value="Subscribe" name="subscribe" class="slim_button"/>
  </form>
</div>';
}
add_shortcode('newsletter_form', 'newsletter_widget');

function twitterfeed_widget($atts){
	$twitterfeed_page = file_get_contents('https://syndication.twitter.com/srv/timeline-profile/screen-name/ProduceBlueBook?dnt=false&embedId=twitter-widget-0&features=eyJ0ZndfdGltZWxpbmVfbGlzdCI6eyJidWNrZXQiOltdLCJ2ZXJzaW9uIjpudWxsfSwidGZ3X2ZvbGxvd2VyX2NvdW50X3N1bnNldCI6eyJidWNrZXQiOnRydWUsInZlcnNpb24iOm51bGx9LCJ0ZndfdHdlZXRfZWRpdF9iYWNrZW5kIjp7ImJ1Y2tldCI6Im9uIiwidmVyc2lvbiI6bnVsbH0sInRmd19yZWZzcmNfc2Vzc2lvbiI6eyJidWNrZXQiOiJvbiIsInZlcnNpb24iOm51bGx9LCJ0ZndfbWl4ZWRfbWVkaWFfMTU4OTciOnsiYnVja2V0IjoidHJlYXRtZW50IiwidmVyc2lvbiI6bnVsbH0sInRmd19leHBlcmltZW50c19jb29raWVfZXhwaXJhdGlvbiI6eyJidWNrZXQiOjEyMDk2MDAsInZlcnNpb24iOm51bGx9LCJ0ZndfZHVwbGljYXRlX3NjcmliZXNfdG9fc2V0dGluZ3MiOnsiYnVja2V0Ijoib24iLCJ2ZXJzaW9uIjpudWxsfSwidGZ3X3ZpZGVvX2hsc19keW5hbWljX21hbmlmZXN0c18xNTA4MiI6eyJidWNrZXQiOiJ0cnVlX2JpdHJhdGUiLCJ2ZXJzaW9uIjpudWxsfSwidGZ3X2xlZ2FjeV90aW1lbGluZV9zdW5zZXQiOnsiYnVja2V0Ijp0cnVlLCJ2ZXJzaW9uIjpudWxsfSwidGZ3X3R3ZWV0X2VkaXRfZnJvbnRlbmQiOnsiYnVja2V0Ijoib24iLCJ2ZXJzaW9uIjpudWxsfX0%3D&frame=false&hideBorder=true&hideFooter=true&hideHeader=false&hideScrollBar=false&lang=en&limit=3&origin=https%3A%2F%2Fqaproduce.bluebookservices.com%2F&sessionId=99b8ebedab6655ddc519509a36d9c1b887d03b87&showHeader=true&showReplies=false&transparent=true&widgetsVersion=aaf4084522e3a%3A1674595607486');
	
	$twitterfeed_page_array = explode("<body>", $twitterfeed_page);
	$twitterfeed_array = explode("</body>", $twitterfeed_page_array[1]);
	echo '<div id="Twitter">
<h2 class="widget-title" style="margin-top: -15px !important; z-index: 6; background:white; position:relative !important; padding-top:15px !important;">Twitter</h2>
'. $twitterfeed_array[0]. '
<style>
#__next {
	line-height: 0.5em;
}
.r-kzbkwu, .r-1b7u577, #id__5tpe8wv15lg, .r-dnmrzs, .r-13hce6t {
	display:block;
}
.r-1b7u577 {
	float: left;
	width: 50px;
}
 .r-qvutc0 {font-size: 12px;} 
 .r-1cbz2o1 {display:none;} 
 .twitter-timeline {position:relative; z-index:4; } 
 #newsletter {background: white; position: relative; z-index: 6;}
 .r-1q142lx {
	 left: 40px;
 }
 .r-13hce6t {
	 margin-top: -10px;
 }
</style>
<script>
jQuery(function() {
	setTimeout(function(){
	jQuery(".r-1b7u577").each(function(){
		var $this = jQuery(this);
		$this.prependTo($this.next());
	});
	}, 5000);
});
</script>
</div>';
}
add_shortcode('twitterfeed', 'twitterfeed_widget');

function custom_excerpt_link($more){
	global $post;
	return ' ...';
//a	return '<a class="moret_link" href="'. get_permalink($post->ID) . '"> Read More...</a>';
}
add_filter('excerpt_more', 'custom_excerpt_link');
add_action('pre_get_posts', 'custom_search_query');
//add or customize query to add date option selected by user
function custom_search_query($query){
	if($query->is_search){
		if(isset($_POST['date_range'])){
			$query->set('date_query', [
				[
					'after' => 'September 12, 2018',//$_POST['date_range'],
 				 	'inclusive' => true
				]
			]);
		}
	}
}

add_action('wp_enqueue_scripts', 'register_media_javascript', 100);

function register_media_javascript() {
  wp_register_script('mediaelement', plugins_url('wp-mediaelement.min.js', __FILE__), array('jquery'), '4.8.2', true);
  wp_enqueue_script('mediaelement');
}
if ( ! function_exists('cp_post_authors') ) {

// Register Custom Post Type
function cp_post_authors() {

	$labels = array(
		'name'                  => _x( 'Custom Post Authors', 'Post Type General Name', 'text_domain' ),
		'singular_name'         => _x( 'Custom Post Author', 'Post Type Singular Name', 'text_domain' ),
		'menu_name'             => __( 'Custom Post Authors', 'text_domain' ),
		'name_admin_bar'        => __( 'Custom Post Authors', 'text_domain' ),
		'archives'              => __( 'Item Archives', 'text_domain' ),
		'attributes'            => __( 'Item Attributes', 'text_domain' ),
		'parent_item_colon'     => __( 'Parent Item:', 'text_domain' ),
		'all_items'             => __( 'All Items', 'text_domain' ),
		'add_new_item'          => __( 'Add New Item', 'text_domain' ),
		'add_new'               => __( 'Add New', 'text_domain' ),
		'new_item'              => __( 'New Item', 'text_domain' ),
		'edit_item'             => __( 'Edit Item', 'text_domain' ),
		'update_item'           => __( 'Update Item', 'text_domain' ),
		'view_item'             => __( 'View Item', 'text_domain' ),
		'view_items'            => __( 'View Items', 'text_domain' ),
		'search_items'          => __( 'Search Item', 'text_domain' ),
		'not_found'             => __( 'Not found', 'text_domain' ),
		'not_found_in_trash'    => __( 'Not found in Trash', 'text_domain' ),
		'featured_image'        => __( 'Featured Image', 'text_domain' ),
		'set_featured_image'    => __( 'Set featured image', 'text_domain' ),
		'remove_featured_image' => __( 'Remove featured image', 'text_domain' ),
		'use_featured_image'    => __( 'Use as featured image', 'text_domain' ),
		'insert_into_item'      => __( 'Insert into item', 'text_domain' ),
		'uploaded_to_this_item' => __( 'Uploaded to this item', 'text_domain' ),
		'items_list'            => __( 'Items list', 'text_domain' ),
		'items_list_navigation' => __( 'Items list navigation', 'text_domain' ),
		'filter_items_list'     => __( 'Filter items list', 'text_domain' ),
	);
	$args = array(
		'label'                 => __( 'Custom Post Author', 'text_domain' ),
		'description'           => __( 'post authors', 'text_domain' ),
		'labels'                => $labels,
		'supports'              => array( 'title', 'editor', 'thumbnail', 'custom-fields' ),
		'taxonomies'            => array( 'category', 'post_tag' ),
		'hierarchical'          => false,
		'public'                => true,
		'show_ui'               => true,
		'show_in_menu'          => true,
		'menu_position'         => 5,
		'show_in_admin_bar'     => true,
		'show_in_nav_menus'     => true,
		'can_export'            => true,
		'has_archive'           => true,
		'exclude_from_search'   => false,
		'publicly_queryable'    => true,
		'capability_type'       => 'page',
	);
	register_post_type( 'cp_post_authors', $args );

}
add_action( 'init', 'cp_post_authors', 0 );
}


// Font Awesome
add_action( 'wp_enqueue_scripts', 'enqueue_load_fa' );
function enqueue_load_fa() {
 
    wp_enqueue_style( 'load-fa', 'https://maxcdn.bootstrapcdn.com/font-awesome/4.6.3/css/font-awesome.min.css' );
}

// SVG Support
function add_file_types_to_uploads($file_types){
$new_filetypes = array();
$new_filetypes['svg'] = 'image/svg+xml';
$file_types = array_merge($file_types, $new_filetypes );
return $file_types;
}
add_action('upload_mimes', 'add_file_types_to_uploads');


/* Enable search restriction if not the "Article list" is selected for the main screen */
function blue_ml_restrict_search_results($value, $user_search) {
	if ($user_search) {
		return true;
	}
	return $value;
}

add_filter( 'ml_restrict_search_results', 'blue_ml_restrict_search_results', 10, 2);

function add_author_fields($post_id){
	
	$authorarr = get_post_meta($post_id, 'author');
	$aboutauthorarr = get_post_meta($post_id, 'about-author');
	
	if(isset($authorarr) && $authorarr != null && count($authorarr) > 0) add_post_meta($post_id, 'author', $authorarr[0],  true);
	if(isset($aboutauthorarr) && $aboutauthorarr != null && count($aboutauthorarr) > 0) add_post_meta($post_id, 'about-author', $aboutauthorarr[0], true);
	
	return true;
}
add_action('wp_insert_post', 'add_author_fields');

add_filter('pre_get_document_title', 'doc_title');
function doc_title(){
if(is_home() || is_front_page()){
    return get_bloginfo('description'); }
}

function add_html_author_ability()
{
	$role_1 = get_role( 'author' );
	$role_1->add_cap( 'unfiltered_html' );
	$role_2 = get_role( 'administrator' );
	$role_2->add_cap( 'unfiltered_html' );
}
add_action( 'admin_init', 'add_html_author_ability' );

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
		        $popularpost_html .= '<li><a href="'.get_the_permalink().'">'.get_the_title().'</a></li>';
	endwhile;

	return sprintf('<ul class="pp-post-secction">%s</ul>', $popularpost_html);
}
add_shortcode('popularposts', 'popular_posts_shortcode');

function analysis_shortcode($atts){
	$analysis_html = '<hr / style="margin: 0;">';
	//$sticky = get_option( 'sticky_posts' );
	
	for($idx = 1; $idx < 4; $idx++)
	{
		//$query_new_posts = get_post($sticky[$idx]);
		$query_new_posts = get_post(get_option('pin_articles_options_setting_'. $idx)); 
		$author_info_cp = get_option('pin_articles_options_author_'. $idx);
		$author_info_cp_img = 	get_the_post_thumbnail_url($author_info_cp);
			
		if($query_new_posts){
			setup_postdata($query_new_posts);
			
			$analysis_html .= '<a href="'.get_the_permalink($query_new_posts).'">';
			$analysis_html .= '<div class="cell large-3 column post-sub-section">';
			$analysis_html .= '<div class="grid-x"><div class="cell small-9 medium-9 large-9 column">';
					$category_post = get_the_category($query_new_posts->ID);
			//$analysis_html .= '<p class="category_link">';
			//$analysis_html .= '<a href="'.get_category_link($category_post[0]->term_id).'">'.$category_post[0]->name.'</a>';
			//$analysis_html .= '</p>';						
			$analysis_html .= '<h6 class="post_title"><em style="color:black;">'.get_the_title($query_new_posts->ID).'</em></h6>';
			$analysis_html .= '</div><div class="cell small-3 medium-3 large-3 column">';
			$analysis_html .= '<img class="post_author" src="'.$author_info_cp_img.'">';
			$analysis_html .= '</div></div>';
			
			/*			
			if(get_post_meta($query_new_posts->ID, 'short-description')[0]){
				$analysis_html .= get_post_meta($query_new_posts->ID,'short-description', true);
			}else{
				$analysis_html .= substr(get_the_content($query_new_posts->ID), 0, 80);
			}
			*/
			
			$analysis_html .= '</a>';
			
			//$analysis_html .= ' <a href="'.get_the_permalink($query_new_posts).'">Read More...</a>';
			$analysis_html .= '</div><hr / style="margin: 0;">
			
			';
		}
	}

	return $analysis_html;
}
add_shortcode('analysis', 'analysis_shortcode');

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
	echo "<!--". $url. "-->
	";
	$imagelink = file_get_contents($url);
  
	// image string data into base64 
	return base64_encode($imagelink);
}
	
function getAdsWidget_function($key, $pageName, $adTypes, $maxCount, $mobileDevice, $webUserID, $industryType, $guid)
{
	$returnStr = "";

/*
	$url = BBSI_APPS. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget?key=%27BBSIProduceAds%27&pageName=%27ProduceMarketingSite%27&adTypes=%27PMSHPSQ3%27&maxCount=%273%27&pageRequestID=%27'. $guid. '%27&webUserID=%270%27&mobileDevice=%27false%27&industryType=%27P%27';
	$data = array('key' => "%27". $key. "%27", 'pageName' => "%27". $pageName. "%27", 'adTypes' => "%27". $adTypes. "%27", 'maxCount' => "%27". $maxCount. "%27", 'pageRequestID' => "%27". $guid. "%27", 'webUserID' => "%27". $webUserID. "%27", 'mobileDevice' => "%27". $mobileDevice. "%27", 'industryType' => "%27". $industryType. "%27");
	$url = BBSI_APPS. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget';

	$url = BBSI_APPS. '/BBOSWidgets/WidgetHelper.asmx/GetAdsWidget';
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
	//echo $url;

	$options = array(
		'http' => array(
			//'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
			'method'  => 'GET'//,
			//'content' => http_build_query($data)
		)
	);
	
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
function getAdsWidget_shortcode($parms)
{
	$key = 'BBSIProduceAds';
	$pageName = 'ProduceMarketingSite';
	$adTypes = 'IA,IA_180x90';
	$maxCount = "1";
	$webUserID = "0";
	$industryType = "P";
	$guid = GUID();
	
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

	$json = getAdsWidget_function($key, $pageName, $adTypes, $maxCount, $mobileDevice, $webUserID, $industryType, $guid);
	$jsonObj = json_decode($json);
	$html = '<div id="AD_'. str_replace(",", "_", $adTypes). '_'. $maxCount. '" style="display:none;">'. $jsonObj->d. '</div>
		';
	return $html;
}
function getAdsWidget_ajax()
{
	$key = 'BBSIProduceAds';
	$pageName = 'ProduceMarketingSite';
	$adTypes = 'IA,IA_180x90';
	$maxCount = "1";
	$mobileDevice = "false";
	$webUserID = "0";
	$industryType = "P";
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

function remove_meta_boxes() {
  # Removes meta from Posts #
  remove_meta_box('postexcerpt','post','normal' ); 
  remove_meta_box('postcustom','post','normal');
  remove_meta_box('trackbacksdiv','post','normal');
  remove_meta_box('commentstatusdiv','post','normal');
  remove_meta_box('commentsdiv','post','normal');
  # Removes meta from pages #
  remove_meta_box('postexcerpt','page','normal'); // optionally use this if page excerpts are enabled
  remove_meta_box('postcustom','page','normal');
  remove_meta_box('trackbacksdiv','page','normal');
  remove_meta_box('commentstatusdiv','page','normal');
  remove_meta_box('commentsdiv','page','normal');
}
add_action('admin_init','remove_meta_boxes');

function insert_fb_in_head() {
    global $post;
    if ( !is_singular()) //if it is not a post or a page
        return;
    if(has_post_thumbnail( $post->ID )) { 
        //$thumbnail_src = wp_get_attachment_image_src( get_post_thumbnail_id( $post->ID ), 'medium' );
		$featured_image_url = wp_get_attachment_url(get_post_thumbnail_id( $post->ID ));
        echo '<meta property="og:image" name="og:image" content="' . $featured_image_url . '"/>';
    }
    echo "
";
}
add_action( 'wp_head', 'insert_fb_in_head', 5 );

// CHW  11/28/2022
add_filter( 'xmlrpc_methods', function( $methods ) {
	unset( $methods['pingback.ping'] );
	return $methods;
} );


add_action('admin_head', 'admin_styles');

function admin_styles() {
    echo '<style>
        body p, body h1 {
			font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif !important;
		}
    </style>';
}

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
	else if(strpos($canonical, "com/produce-news/"))
	{
		$page = preg_replace("/[^0-9]/", "", $_SERVER["REQUEST_URI"] );
		if($page != "")
		{
			$page = intval($page);
		}
		
		$canonical = str_replace("com/produce-news/", "com". $_SERVER["REQUEST_URI"], $canonical);
		
		if($page > 1)
		{
			if($page == 2)
			{
				echo '
		<link rel="prev" href="https://'. $_SERVER["SERVER_NAME"]. '/produce-news/" />';
			}
			else
			{
				echo '
		<link rel="prev" href="https://'. $_SERVER["SERVER_NAME"]. '/produce-news/page/'. ($page-1). '" />';
			}
			echo '
		<link rel="next" href="https://'. $_SERVER["SERVER_NAME"]. '/produce-news/page/'. ($page+1). '" />
		';
		}
		else
		{
			echo '
		<link rel="next" href="https://'. $_SERVER["SERVER_NAME"]. '/produce-news/page/2/" />
		';
		}
	}
    return strtolower($canonical);
}   
add_filter( 'wpseo_canonical', 'prefix_filter_canonical_example', 20 );


add_filter( 'wp_smush_skip_folder', function( $skip, $path ) {
	
	$to_unlock = array( '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023' );
	
	$upload_dir = wp_upload_dir();
	$base_dir   = $upload_dir['basedir'];
	
	
	foreach ( $to_unlock as $key=>$value ) {
		if ( false !== strpos( $path, $base_dir . '/' . $value ) ) {
			$skip = false;
		}
	}
    
    return $skip;
}, 10, 2 );


function webp_upload_mimes( $existing_mimes ) {
	$existing_mimes['webp'] = 'image/webp'; // add WebP to the list of mime types
	return $existing_mimes; 				// return the array back to the function with our added mime type
}
add_filter( 'mime_types', 'webp_upload_mimes' );

function add_allow_upload_extension_exception( $types, $file, $filename, $mimes ) {
    // Do basic extension validation and MIME mapping
      $wp_filetype = wp_check_filetype( $filename, $mimes );
      $ext         = $wp_filetype['ext'];
      $type        = $wp_filetype['type'];
    if( in_array( $ext, array( 'webp' ) ) ) { // if follows webp files have
      $types['ext'] = $ext;
      $types['type'] = $type;
    }
    return $types;
}
add_filter( 'wp_check_filetype_and_ext', 'add_allow_upload_extension_exception', 99, 4 );
  
//** * Enable preview / thumbnail for webp image files.*/
function webp_is_displayable($result, $path) {
    if ($result === false) {
        $displayable_image_types = array( IMAGETYPE_WEBP );
        $info = @getimagesize( $path );

        if (empty($info)) {
            $result = false;
        } elseif (!in_array($info[2], $displayable_image_types)) {
            $result = false;
        } else {
            $result = true;
        }
    }

    return $result;
}
add_filter('file_is_displayable_image', 'webp_is_displayable', 10, 2);

function wp_update_attachment_url_domain ($url, $post_id)
{
	if(!file_exists(str_replace('/', '\\', str_replace('https://qaproduce.bluebookservices.com', 'D:\\Applications\\MarketingSites\\Produce', $url)))) {
		$url = str_ireplace('qaproduce.bluebookservices.com', 'www.producebluebook.com', $url);
	}

   return $url;
}
add_filter( 'wp_get_attachment_url', 'wp_update_attachment_url_domain', 10, 2 );
