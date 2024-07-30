		<footer id="footer" class="source-org vcard copyright wrap">
			<div class="left">
			<?php wp_nav_menu( array('menu' => 'footer-nav' )); ?>
			</div>
			<div class="right login">
				<ul>
					<li><a href="/bbos-Login/">Member Login</a></li>
				</ul>
			<small>&copy;&nbsp;<?php echo date("Y"); echo " "; bloginfo('name'); ?></small>
			<!-- Social media icons -->
			<div width: 147px; style="margin-top: 7px;">
			<a href="https://www.youtube.com/BlueBookServices" target="_blank"><img src="https://www.bluebookservices.com/wp-content/uploads/sites/3/2018/06/YouTube.png" alt="Blue Book Services Youtube" width="32px" height="32px" title="Blue Book Services Youtube"/></a>
			</div>
			</div>
			<div class="clearfix"></div>
		</footer>

	
	<?php wp_footer(); ?>


<!-- here comes the javascript -->

<!-- jQuery is called via the Wordpress-friendly way via functions.php -->

<!-- this is where we put our custom functions -->
<script src="<?php bloginfo('template_directory'); ?>/_/js/jquery.nivo.slider.pack.js"></script>
<script src="<?php bloginfo('template_directory'); ?>/_/js/functions.js"></script>


<!-- Asynchronous google analytics; this is the official snippet.
	 Replace UA-XXXXXX-XX with your site's ID and uncomment to enable.
	 
<script>

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-XXXXXX-XX']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
-->
	
</body>

</html>