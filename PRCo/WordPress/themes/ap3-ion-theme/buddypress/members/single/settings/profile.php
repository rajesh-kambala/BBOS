<?php do_action( 'bp_before_member_settings_template' ); ?>

<form action="<?php echo trailingslashit( bp_displayed_user_domain() . bp_get_settings_slug() . '/profile' ); ?>" method="post" class="standard-form list" id="settings-form">

	<?php if ( bp_xprofile_get_settings_fields() ) : ?>

		<?php while ( bp_profile_groups() ) : bp_the_profile_group(); ?>

			<?php if ( bp_profile_fields() ) : ?>

				<div class="profile-settings padding" id="xprofile-settings-<?php bp_the_profile_group_slug(); ?>">
					<h4 class="title field-group-name"><?php bp_the_profile_group_name(); ?></h4>
					<?php _e( 'Visibility', 'ap3-ion-theme' ); ?>
				</div>

				<?php while ( bp_profile_fields() ) : bp_the_profile_field(); ?>

					<div class="item item-text-wrap">
						<p class="field-name"><?php bp_the_profile_field_name(); ?></p>
						<p class="field-visibility"><?php bp_profile_settings_visibility_select(); ?></p>
					</div>

				<?php endwhile; ?>

			<?php endif; ?>

		<?php endwhile; ?>

	<?php endif; ?>

	<?php do_action( 'bp_core_xprofile_settings_before_submit' ); ?>

	<div class="submit padding">
		<input id="submit" type="submit" name="xprofile-settings-submit" value="<?php esc_attr_e( 'Save Settings', 'ap3-ion-theme' ); ?>" class="auto button button-primary button-block" />
	</div>

	<?php do_action( 'bp_core_xprofile_settings_after_submit' ); ?>

	<?php wp_nonce_field( 'bp_xprofile_settings' ); ?>

	<input type="hidden" name="field_ids" id="field_ids" value="<?php bp_the_profile_group_field_ids(); ?>" />

</form>

<?php do_action( 'bp_after_member_settings_template' );
