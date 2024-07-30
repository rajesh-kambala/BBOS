<?php
/**
 * @package AppBuddy Login/Registration template
 */
?>
<!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>" />

<title><?php wp_title( '|', true, 'right' ); ?></title>
<link rel="profile" href="http://gmpg.org/xfn/11" />
<link rel="pingback" href="<?php bloginfo( 'pingback_url' ); ?>" />
<meta name="apple-mobile-web-app-capable" content="yes">
<?php wp_head(); ?>
</head>

<body <?php body_class('login-modal'); ?>>

<div id="body-container">

		<div id="menu-content" class="menu-content pane menu-animated">

			<header class="bar bar-header">

				<?php if ( !bp_is_register_page() ) : ?>
					<a href="<?php echo home_url() . '/' . BP_REGISTER_SLUG; ?>" class="button nav-left-btn"><?php _e( 'Register', 'ap3-ion-theme' ); ?></a>
				<?php else: ?>
					<a href="#loginModal" class="button nav-left-btn io-modal-open"><?php _e( 'Login', 'ap3-ion-theme' ); ?></a>
				<?php endif; ?>

				<?php if ( !bp_is_register_page() ) : ?>
					<a href="#app-lost-password" class="io-modal-open button nav-left-btn"><?php _e( 'Lost Password', 'ap3-ion-theme' ); ?></a>
				<?php endif; ?>

			</header><!-- #masthead -->

			<div id="page" class="hfeed site">
				<?php do_action( 'appp_before' ); ?>

				<div id="main" <?php body_class( 'site-main' ); ?>>


			<?php if ( bp_is_register_page() ) : ?>

			<form action="" name="signup_form" id="signup_form" class="standard-form list" method="post" enctype="multipart/form-data">

			<div class="padding">

			<?php if ( 'registration-disabled' == bp_get_current_signup_step() ) : ?>
				<?php do_action( 'template_notices' ); ?>
				<?php do_action( 'bp_before_registration_disabled' ); ?>

					<p><?php _e( 'User registration is currently not allowed.', 'ap3-ion-theme' ); ?></p>

				<?php do_action( 'bp_after_registration_disabled' ); ?>
			<?php endif; // registration-disabled signup setp ?>

			<?php if ( 'request-details' == bp_get_current_signup_step() ) : ?>

				<?php do_action( 'template_notices' ); ?>

				<p><?php _e( 'Registering for this site is easy. Just fill in the fields below, and we\'ll get a new account set up for you in no time.', 'ap3-ion-theme' ); ?></p>

				<?php do_action( 'bp_before_account_details_fields' ); ?>

			</div>

				<div class="register-section" id="basic-details-section">

					<?php /***** Basic Account Details ******/ ?>

					<h4 class="padding"><?php _e( 'Account Details', 'ap3-ion-theme' ); ?></h4>
					
					<?php do_action( 'bp_signup_username_errors' ); ?>
					<label for="signup_username" class="item item-input">
					<input type="text" name="signup_username" id="signup_username" value="<?php bp_signup_username_value(); ?>" placeholder="<?php _e( 'Username', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>" />
					</label>

					<?php do_action( 'bp_signup_email_errors' ); ?>
					<label for="signup_email" class="item item-input">
					
					<input type="text" name="signup_email" id="signup_email" value="<?php bp_signup_email_value(); ?>" placeholder="<?php _e( 'Email Address', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>" />
					</label>

					<?php do_action( 'bp_signup_password_errors' ); ?>
					<label for="signup_password" class="item item-input">
					<input type="password" name="signup_password" id="signup_password" value="" placeholder="<?php _e( 'Choose a Password', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>" />
					</label>

					<label for="signup_password_confirm" class="item item-input">
					<input type="password" name="signup_password_confirm" id="signup_password_confirm" value="" placeholder="<?php _e( 'Confirm Password', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>
					<?php do_action( 'bp_signup_password_confirm_errors' ); ?>" />
					</label>

					<?php do_action( 'bp_account_details_fields' ); ?>

				</div><!-- #basic-details-section -->

				<?php do_action( 'bp_after_account_details_fields' ); ?>

				<?php /***** Extra Profile Details ******/ ?>

				<?php if ( bp_is_active( 'xprofile' ) ) : ?>

					<?php do_action( 'bp_before_signup_profile_fields' ); ?>

					<div class="register-section" id="profile-details-section">

						<h4 class="padding"><?php _e( 'Profile Details', 'ap3-ion-theme' ); ?></h4>

						<?php /* Use the profile field loop to render input fields for the 'base' profile field group */ ?>
						<?php if ( bp_is_active( 'xprofile' ) ) : if ( bp_has_profile( array( 'profile_group_id' => 1, 'fetch_field_data' => false ) ) ) : while ( bp_profile_groups() ) : bp_the_profile_group(); ?>

						<?php while ( bp_profile_fields() ) : bp_the_profile_field(); ?>

							<div class="editfield item">

								<?php
								$field_type = bp_xprofile_create_field_type( bp_get_the_profile_field_type() );
								$field_type->edit_field_html();

								do_action( 'bp_custom_profile_edit_fields_pre_visibility' );

								if ( bp_current_user_can( 'bp_xprofile_change_field_visibility' ) ) : ?>
									<p class="field-visibility-settings-toggle" id="field-visibility-settings-toggle-<?php bp_the_profile_field_id() ?>">
										<?php printf( __( 'This field can be seen by: <span class="current-visibility-level">%s</span>', 'ap3-ion-theme' ), bp_get_the_profile_field_visibility_level_label() ) ?> <a href="#" class="visibility-toggle-link"><?php _ex( 'Change', 'Change profile field visibility level', 'ap3-ion-theme' ); ?></a>
									</p>

									<div class="field-visibility-settings" id="field-visibility-settings-<?php bp_the_profile_field_id() ?>">
										<fieldset>
											<legend><?php _e( 'Who can see this field?', 'ap3-ion-theme' ) ?></legend>

											<?php bp_profile_visibility_radio_buttons() ?>

										</fieldset>
										<a class="field-visibility-settings-close" href="#"><?php _e( 'Close', 'ap3-ion-theme' ) ?></a>

									</div>
								<?php else : ?>
									<p class="field-visibility-settings-notoggle" id="field-visibility-settings-toggle-<?php bp_the_profile_field_id() ?>">
										<?php printf( __( 'This field can be seen by: <span class="current-visibility-level">%s</span>', 'ap3-ion-theme' ), bp_get_the_profile_field_visibility_level_label() ) ?>
									</p>
								<?php endif ?>

								<?php do_action( 'bp_custom_profile_edit_fields' ); ?>

								<p class="description"><?php bp_the_profile_field_description(); ?></p>

							</div>

						<?php endwhile; ?>

						<input type="hidden" name="signup_profile_field_ids" id="signup_profile_field_ids" value="<?php bp_the_profile_group_field_ids(); ?>" />

						<?php endwhile; endif; endif; ?>

						<?php do_action( 'bp_signup_profile_fields' ); ?>

					</div><!-- #profile-details-section -->

					<?php do_action( 'bp_after_signup_profile_fields' ); ?>

				<?php endif; ?>

				<?php if ( bp_get_blog_signup_allowed() ) : ?>

					<?php do_action( 'bp_before_blog_details_fields' ); ?>

					<?php /***** Blog Creation Details ******/ ?>

					<div class="register-section" id="blog-details-section">

						<h4><?php _e( 'Blog Details', 'ap3-ion-theme' ); ?></h4>

						<p><input type="checkbox" name="signup_with_blog" id="signup_with_blog" value="1"<?php if ( (int) bp_get_signup_with_blog_value() ) : ?> checked="checked"<?php endif; ?> /> <?php _e( 'Yes, I\'d like to create a new site', 'ap3-ion-theme' ); ?></p>

						<div id="blog-details"<?php if ( (int) bp_get_signup_with_blog_value() ) : ?>class="show"<?php endif; ?>>

							<label for="signup_blog_url" class="item item-input"><?php _e( 'Blog URL', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>
							<?php do_action( 'bp_signup_blog_url_errors' ); ?>

							<?php if ( is_subdomain_install() ) : ?>
								http:// <input type="text" name="signup_blog_url" id="signup_blog_url" value="<?php bp_signup_blog_url_value(); ?>" /> .<?php bp_blogs_subdomain_base(); ?>
							<?php else : ?>
								<?php echo home_url( '/' ); ?> <input type="text" name="signup_blog_url" id="signup_blog_url" value="<?php bp_signup_blog_url_value(); ?>" />
							<?php endif; ?>

							</label>

							<label for="signup_blog_title" class="item item-input"><?php _e( 'Site Title', 'ap3-ion-theme' ); ?> <?php _e( '(required)', 'ap3-ion-theme' ); ?>
							<?php do_action( 'bp_signup_blog_title_errors' ); ?>
							<input type="text" name="signup_blog_title" id="signup_blog_title" value="<?php bp_signup_blog_title_value(); ?>" />

							</label>

							<span class="label"><?php _e( 'I would like my site to appear in search engines, and in public listings around this network.', 'ap3-ion-theme' ); ?>:</span>
							<?php do_action( 'bp_signup_blog_privacy_errors' ); ?>

							<label><input type="radio" name="signup_blog_privacy" id="signup_blog_privacy_public" value="public"<?php if ( 'public' == bp_get_signup_blog_privacy_value() || !bp_get_signup_blog_privacy_value() ) : ?> checked="checked"<?php endif; ?> /> <?php _e( 'Yes', 'ap3-ion-theme' ); ?></label>
							<label><input type="radio" name="signup_blog_privacy" id="signup_blog_privacy_private" value="private"<?php if ( 'private' == bp_get_signup_blog_privacy_value() ) : ?> checked="checked"<?php endif; ?> /> <?php _e( 'No', 'ap3-ion-theme' ); ?></label>

							<?php do_action( 'bp_blog_details_fields' ); ?>

						</div>

					</div><!-- #blog-details-section -->

					<?php do_action( 'bp_after_blog_details_fields' ); ?>

				<?php endif; ?>

				<?php do_action( 'bp_before_registration_submit_buttons' ); ?>

				<div class="submit">
					<input type="submit" name="signup_submit" id="signup_submit" class="button button-primary button-block" value="<?php esc_attr_e( 'Sign Up', 'ap3-ion-theme' ); ?>" />
				</div>

				<?php do_action( 'bp_after_registration_submit_buttons' ); ?>

				<?php wp_nonce_field( 'bp_new_signup' ); ?>

			<?php endif; // request-details signup step ?>

			<?php if ( 'completed-confirmation' == bp_get_current_signup_step() ) : ?>

				<?php do_action( 'template_notices' ); ?>
				<?php do_action( 'bp_before_registration_confirmed' ); ?>

				<?php if ( bp_registration_needs_activation() ) : ?>
					<p><?php _e( 'You have successfully created your account! To begin using this site you will need to activate your account via the email we have just sent to your address.', 'ap3-ion-theme' ); ?></p>
				<?php else : ?>
					<p><?php _e( 'You have successfully created your account! Please log in using the username and password you have just created.', 'ap3-ion-theme' ); ?></p>
				<?php endif; ?>

				<?php do_action( 'bp_after_registration_confirmed' ); ?>

			<?php endif; // completed-confirmation signup step ?>

			<?php do_action( 'bp_custom_signup_steps' ); ?>

			</form>


			<?php else: ?>

			<?php if( isset( $_REQUEST['error'] ) && $_REQUEST['error'] == 'login_failed' ) : ?>

				<div class="login-modal-message error">
					<p><?php _e('Username or password incorrect.', 'ap3-ion-theme'); ?></p>
				</div>

			<?php endif; ?>

			<?php if( get_theme_mod( 'ab_text_mod' ) != '') : ?>
					<div class="login-modal-text">
						<p><?php echo get_theme_mod( 'ab_text_mod'); ?></p>
					</div>

			<?php endif; ?>

			<?php do_action( 'appbuddy_before_loginform' ); ?>

			<form autocomplete = "off" autocapitalize="off" name="appbuddy-loginform" id="appbuddy-loginform" method="post" class="list">
				<p class="status"></p>

				<label class="item item-input">
					<input type="text" name="username" id="username" class="input" placeholder="<?php esc_attr_e( 'Username', 'ap3-ion-theme' ); ?>" value="" size="20" />
				</label>

				<label class="item item-input">
					<input type="password" name="password" id="password" class="input" placeholder="<?php esc_attr_e( 'Password', 'ap3-ion-theme' ); ?>" value="" size="20" />
				</label>

				<input name="rememberme" type="hidden" id="rememberme" value="forever" />
				<?php wp_nonce_field( 'ajax-login-nonce', 'security' ); ?>
				<p class="login-submit">
					<input type="submit" name="wp-submit" id="wp-submit" class="button button-primary button-block" value="<?php esc_attr_e( 'Log In', 'ap3-ion-theme' ); ?>" />
				</p>

				<?php do_action( 'appbuddy_after_loginform' ); ?>

			</form>

			<?php endif; ?>


		</div><!-- #main -->

		<?php wp_footer(); ?>
	</body>
</html>