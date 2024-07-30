<div id="buddypress">

	<div id="item-header" role="complementary">

		<?php
		/**
		 * If the cover image feature is enabled, use a specific header
		 */
		if ( bp_displayed_user_use_cover_image_header() ) :
			bp_get_template_part( 'members/single/cover-image-header' );
		else :
			bp_get_template_part( 'members/single/member-header' );
		endif;
		?>

	</div><!-- #item-header -->

	<button id="member-nav" class="button button-secondary button-block icon-left ion-navicon"><?php echo apply_filters('appbuddy_nav_title', __('Navigation', 'ap3-ion-theme') ) ?></button>

	<div id="item-nav">
		<div class="item-list-tabs menu-type-tabs" id="object-nav" role="navigation">
			<ul class="user-nav">

				<?php bp_get_displayed_user_nav(); ?>

			</ul>
		</div>
	</div><!-- #item-nav -->

	<?php

		// Subnav title

		if( bp_is_user_groups() ) {
			$subnav_title = __( 'Groups', 'ap3-ion-theme' );			
		} else if( bp_is_user_messages() ) {
			$subnav_title = __( 'Messages', 'ap3-ion-theme' );
		} else if( bp_is_user_profile() ) {
			$subnav_title = __( 'Profile', 'ap3-ion-theme' );
		} else if( bp_is_user_notifications() ) {
			$subnav_title = __( 'Notifications', 'ap3-ion-theme' );
		} else if( bp_is_user_settings() ) {
			$subnav_title = __( 'User Settings', 'ap3-ion-theme' );
		} else {
			$subnav_title = '';
		}

		$subnav_title = apply_filters( 'appbuddy_subnav_title', $subnav_title );
		$subnav_class = ( $subnav_title ) ? 'has-subnav' : 'has-no-subnav';

		// Subnav button

	if( $subnav_title ) : ?>
		<button id="sub-nav-button" class="button button-secondary button-block icon-left ion-navicon"><?php echo $subnav_title ?></button>
	<?php endif; ?>
	
	<div id="item-body" class="<?php echo $subnav_class ?>" role="main">

		<?php

		if ( bp_is_user_activity() || !bp_current_component() ) :
			bp_get_template_part( 'members/single/activity' );

		elseif ( bp_is_user_blogs() ) :
			bp_get_template_part( 'members/single/blogs'    );

		elseif ( bp_is_user_friends() ) :
			bp_get_template_part( 'members/single/friends'  );

		elseif ( bp_is_user_groups() ) :
			bp_get_template_part( 'members/single/groups'   );

		elseif ( bp_is_user_messages() ) :
			bp_get_template_part( 'members/single/messages' );

		elseif ( bp_is_user_profile() ) :
			bp_get_template_part( 'members/single/profile'  );

		elseif ( bp_is_user_forums() ) :
			bp_get_template_part( 'members/single/forums'   );

		elseif ( bp_is_user_notifications() ) :
			bp_get_template_part( 'members/single/notifications' );

		elseif ( bp_is_user_settings() ) :
			bp_get_template_part( 'members/single/settings' );

		// If nothing sticks, load a generic template
		else :
			bp_get_template_part( 'members/single/plugins'  );

		endif;

		 ?>

	</div><!-- #item-body -->
	
</div><!-- #buddypress -->
