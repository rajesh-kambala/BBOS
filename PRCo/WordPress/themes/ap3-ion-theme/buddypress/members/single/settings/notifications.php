<?php do_action( 'bp_before_member_settings_template' ); ?>

<form action="<?php echo bp_displayed_user_domain() . bp_get_settings_slug() . '/notifications'; ?>" method="post" class="standard-form" id="settings-form">
	<p><?php _e( 'Send an email notice when:', 'ap3-ion-theme' ); ?></p>

	<div class="list">

	<?php do_action( 'bp_notification_settings' ); ?>

	</div>

	<div class="submit padding">
		<input type="submit" class="button button-primary button-block" name="submit" value="<?php esc_attr_e( 'Save Changes', 'ap3-ion-theme' ); ?>" id="submit" class="auto" />
	</div>

	<?php do_action( 'bp_members_notification_settings_after_submit' ); ?>

	<?php wp_nonce_field('bp_settings_notifications' ); ?>

</form>

<?php do_action( 'bp_after_member_settings_template' ); ?>
