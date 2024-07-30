<?php do_action( 'bp_before_member_settings_template' ); ?>

<form action="<?php echo bp_displayed_user_domain() . bp_get_settings_slug() . '/general'; ?>" method="post" class="standard-form list" id="settings-form">

	<?php if ( !is_super_admin() ) : ?>

		<label for="pwd" class="item item-input item-stacked-label">
			<span class="input-label"><?php _e( 'Current Password <span>(required to update email or change current password)</span>', 'ap3-ion-theme' ); ?></span>
			<input type="password" name="pwd" id="pwd" size="16" value="" class="settings-input small" /> 
		</label>

		<a href="<?php echo wp_lostpassword_url(); ?>" title="<?php esc_attr_e( 'Password Lost and Found', 'ap3-ion-theme' ); ?>"><?php _e( 'Lost your password?', 'ap3-ion-theme' ); ?></a>

	<?php endif; ?>

	<label for="email" class="item item-input item-stacked-label">
		<span class="input-label"><?php _e( 'Account Email', 'ap3-ion-theme' ); ?></span>
		<input type="text" name="email" id="email" value="<?php echo bp_get_displayed_user_email(); ?>" class="settings-input" />
	</label>

	<h4 class="padding"><?php _e( 'Change Password?', 'ap3-ion-theme' ); ?></h4>

	<label for="pass1" class="item item-input item-stacked-label">
		<span class="input-label"><?php _e( 'New password <span>(leave blank for no change)</span>', 'ap3-ion-theme' ); ?></span>
		<input type="password" name="pass1" id="pass1" size="16" value="" class="settings-input small" />
	</label>

	<label for="pass2" class="item item-input item-stacked-label">
		<span class="input-label"><?php _e( 'Repeat New Password', 'ap3-ion-theme' ); ?></span>
		<input type="password" name="pass2" id="pass2" size="16" value="" class="settings-input small" />
	</label>

	<?php do_action( 'bp_core_general_settings_before_submit' ); ?>

	<div class="submit padding">
		<input type="submit" class="button button-block" name="submit" value="<?php esc_attr_e( 'Save Changes', 'ap3-ion-theme' ); ?>" id="submit" class="auto" />
	</div>

	<?php do_action( 'bp_core_general_settings_after_submit' ); ?>

	<?php wp_nonce_field( 'bp_settings_general' ); ?>

</form>

<?php do_action( 'bp_after_member_settings_template' ); ?>
