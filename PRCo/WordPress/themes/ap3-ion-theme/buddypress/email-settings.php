<?php
/**
 * Functions to replace notification settings table with HTML markup for Ion Theme
 *
 * @return text HTML content 
 **/
function bs_bp_activity_screen_notification_settings() {
	if ( !$mention = bp_get_user_meta( bp_displayed_user_id(), 'notification_activity_new_mention', true ) )
		$mention = 'yes';
	if ( !$reply = bp_get_user_meta( bp_displayed_user_id(), 'notification_activity_new_reply', true ) )
		$reply = 'yes'; ?>

	<div class="padding">

	<h4><?php _e( 'Activity', 'ap3-ion-theme' ) ?></h4>

	<?php printf( __( 'A member mentions you in an update using "@%s"', 'ap3-ion-theme' ), bp_core_get_username( bp_displayed_user_id() ) ) ?>

	</div>

	<label class="item">
      <input type="radio" name="notifications[notification_activity_new_mention]" value="yes" <?php checked( $mention, 'yes', true ) ?>/>
      Yes
    </label>

    <label class="item">
      <input type="radio" name="notifications[notification_activity_new_mention]" value="no" <?php checked( $mention, 'no', true ) ?>/>
      No
    </label>

    <p class="padding"><?php _e( "A member replies to an update or comment you've posted", 'ap3-ion-theme' ) ?></p>

    <label class="item">
      <input type="radio" name="notifications[notification_activity_new_reply]" value="yes" <?php checked( $reply, 'yes', true ) ?>/>
          Yes
    </label>

    <label class="item">
      <input type="radio" name="notifications[notification_activity_new_reply]" value="no" <?php checked( $reply, 'no', true ) ?>/>
          No
    </label>

<?php
}
remove_action( 'bp_notification_settings', 'bp_activity_screen_notification_settings', 1 );
add_action( 'bp_notification_settings', 'bs_bp_activity_screen_notification_settings', 1 );
/**
 * Function to replace notification settings table with similar HTML with Twitter Bootstrap
 *
 * @return text HTML content 
 **/
function bs_friends_screen_notification_settings() {
	if ( !$send_requests = bp_get_user_meta( bp_displayed_user_id(), 'notification_friends_friendship_request', true ) )
		$send_requests   = 'yes';
	if ( !$accept_requests = bp_get_user_meta( bp_displayed_user_id(), 'notification_friends_friendship_accepted', true ) )
		$accept_requests = 'yes'; ?>

	<div class="padding">

		<h4><?php _e( 'Friends', 'ap3-ion-theme' ) ?></h4>

		<?php _e( 'A member sends you a friendship request', 'ap3-ion-theme' ) ?>

	</div>
	
	<label class="item">
		<input type="radio" name="notifications[notification_friends_friendship_request]" value="yes" <?php checked( $send_requests, 'yes', true ) ?>/>
		Yes
	</label>
	
	<label class="item">
		<input type="radio" name="notifications[notification_friends_friendship_request]" value="no" <?php checked( $send_requests, 'no', true ) ?>/>
		No
	</label>

	<p class="padding"><?php _e( 'A member accepts your friendship request', 'ap3-ion-theme' ) ?></p>


	<label class="item">
		<input type="radio" name="notifications[notification_friends_friendship_accepted]" value="yes" <?php checked( $accept_requests, 'yes', true ) ?>/>
		Yes
	</label>

	<label class="item">
		<input type="radio" name="notifications[notification_friends_friendship_accepted]" value="no" <?php checked( $accept_requests, 'no', true ) ?>/>
		No
	</label>

<?php
}
remove_action( 'bp_notification_settings', 'friends_screen_notification_settings' );
add_action( 'bp_notification_settings', 'bs_friends_screen_notification_settings' );
function bs_messages_screen_notification_settings() {
	if ( bp_action_variables() ) {
		bp_do_404();
		return;
	}
	if ( !$new_messages = bp_get_user_meta( bp_displayed_user_id(), 'notification_messages_new_message', true ) )
		$new_messages = 'yes';
	if ( !$new_notices = bp_get_user_meta( bp_displayed_user_id(), 'notification_messages_new_notice', true ) )
		$new_notices  = 'yes'; ?>

	<div class="padding">

		<h4><?php _e( 'Messages', 'ap3-ion-theme' ) ?></h4>

		<?php _e( 'A member sends you a new message', 'ap3-ion-theme' ) ?>

	</div>

	<label class="item">
		<input type="radio" name="notifications[notification_messages_new_message]" value="yes" <?php checked( $new_messages, 'yes', true ) ?>/>
		Yes
	</label>

	<label class="item">
		<input type="radio" name="notifications[notification_messages_new_message]" value="no" <?php checked( $new_messages, 'no', true ) ?>/>
		No
	</label>
	
	<p class="padding"><?php _e( 'A new site notice is posted', 'ap3-ion-theme' ) ?></p>
	
	<label class="item">
		<input type="radio" name="notifications[notification_messages_new_notice]" value="yes" <?php checked( $new_notices, 'yes', true ) ?>/>
		Yes
	</label>
	
	<label class="item">
		<input type="radio" name="notifications[notification_messages_new_notice]" value="no" <?php checked( $new_notices, 'no', true ) ?>/>
		No
	</label>


<?php
}
remove_action( 'bp_notification_settings', 'messages_screen_notification_settings', 2 );
add_action( 'bp_notification_settings', 'bs_messages_screen_notification_settings' );
function bs_groups_screen_notification_settings() {
	if ( !$group_invite = bp_get_user_meta( bp_displayed_user_id(), 'notification_groups_invite', true ) )
		$group_invite  = 'yes';
	if ( !$group_update = bp_get_user_meta( bp_displayed_user_id(), 'notification_groups_group_updated', true ) )
		$group_update  = 'yes';
	if ( !$group_promo = bp_get_user_meta( bp_displayed_user_id(), 'notification_groups_admin_promotion', true ) )
		$group_promo   = 'yes';
	if ( !$group_request = bp_get_user_meta( bp_displayed_user_id(), 'notification_groups_membership_request', true ) )
		$group_request = 'yes';
?>

	<div class="padding">
		<h4><?php _e( 'Groups', 'ap3-ion-theme' ) ?></h4>

		<?php _e( 'A member invites you to join a group', 'ap3-ion-theme' ) ?>
	</div>
	
	<label class="item">
		<input type="radio" name="notifications[notification_groups_invite]" value="yes" <?php checked( $group_invite, 'yes', true ) ?>/>
		Yes
	</label>
	
	<label class="item">
		<input type="radio" name="notifications[notification_groups_invite]" value="no" <?php checked( $group_invite, 'no', true ) ?>/>
		No
	</label>

	<p class="padding"><?php _e( 'Group information is updated', 'ap3-ion-theme' ) ?></p>
	
	<label class="item">
		<input type="radio" name="notifications[notification_groups_group_updated]" value="yes" <?php checked( $group_update, 'yes', true ) ?>/>
		Yes
	</label>

	<label class="item">
		<input type="radio" name="notifications[notification_groups_group_updated]" value="no" <?php checked( $group_update, 'no', true ) ?>/>
		No
	</label>
	
	<p class="padding"><?php _e( 'You are promoted to a group administrator or moderator', 'ap3-ion-theme' ) ?></p>
	
	<label class="item">
		<input type="radio" name="notifications[notification_groups_admin_promotion]" value="yes" <?php checked( $group_promo, 'yes', true ) ?>/>
		Yes
	</label>

	<label class="item">
		<input type="radio" name="notifications[notification_groups_admin_promotion]" value="no" <?php checked( $group_promo, 'no', true ) ?>/>
		No
	</label>
	
	<p class="padding"><?php _e( 'A member requests to join a private group for which you are an admin', 'ap3-ion-theme' ) ?></p>

	<label class="item">
		<input type="radio" name="notifications[notification_groups_membership_request]" value="yes" <?php checked( $group_request, 'yes', true ) ?>/>
		Yes
	</label>
	
	<label class="item">
		<input type="radio" name="notifications[notification_groups_membership_request]" value="no" <?php checked( $group_request, 'no', true ) ?>/>
		No
	</label>

<?php
}
remove_action( 'bp_notification_settings', 'groups_screen_notification_settings' );
add_action( 'bp_notification_settings', 'bs_groups_screen_notification_settings' );