
<div class="cat-select">
    <select id="cat-list">
        <?php
        $categories = get_categories();
            foreach ($categories as $cat) {
            echo '<option value="'. $cat->category_nicename .'"> '. $cat->name .' </option>';
            } 
        ?>
    </select>
  </div>

  <?php 
     $categories = get_categories();
        foreach ($categories as $cat) {
        echo '<div id="' . $cat->category_nicename . '" class="content">' . do_shortcode("[catlist id='$cat->term_id' numberposts=10]") . '</div>'; 
        }
    ?>

<div id="sidebar">

    <?php if (function_exists('dynamic_sidebar') && dynamic_sidebar('Left Sidebar')) : else : ?>
    
        <!-- All this stuff in here only shows up if you DON'T have any widgets active in this zone -->

    	<?php get_search_form(); ?>
    
    	<?php wp_list_pages('title_li=<h2>Pages</h2>' ); ?>
    
    	<h2>Archives</h2>
    	<ul>
    		<?php wp_get_archives('type=monthly'); ?>
    	</ul>
        
        <h2>Categories</h2>
        <ul>
    	   <?php wp_list_categories('show_count=1&title_li='); ?>
        </ul>
        
    	<?php wp_list_bookmarks(); ?>
    
    	<h2>Meta</h2>
    	<ul>
    		<?php wp_register(); ?>
    		<li><?php wp_loginout(); ?></li>
    		<li><a href="http://wordpress.org/" title="Powered by WordPress, state-of-the-art semantic personal publishing platform.">WordPress</a></li>
    		<?php wp_meta(); ?>
    	</ul>
    	
    	<h2>Subscribe</h2>
    	<ul>
    		<li><a href="<?php bloginfo('rss2_url'); ?>">Entries (RSS)</a></li>
    		<li><a href="<?php bloginfo('comments_rss2_url'); ?>">Comments (RSS)</a></li>
    	</ul>
	
	<?php endif; ?>

    <!--add other items here to show within the left sidebar area for the news and insights pages-->
    <span id="BBSIOAContent01" ></span>
</div>