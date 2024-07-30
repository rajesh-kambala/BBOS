<?php
/**
 * BuddyPress - Groups Cover Image Header.
 *
 * @package BuddyPress
 * @subpackage bp-legacy
 */

/**
 * Fires before the display of a group's header.
 *
 * @since 1.2.0
 */
do_action( 'bp_before_group_header' ); ?>

<div id="cover-image-container">
	<div id="header-cover-image">

		<div id="item-header-cover-image">

			<div class="item member-header">

			<?php if ( ! bp_disable_group_avatar_uploads() ) : ?>
				<div id="item-header-avatar">
					<a href="<?php bp_group_permalink(); ?>" title="<?php bp_group_name(); ?>">

						<?php bp_group_avatar(); ?>

					</a>
				</div><!-- #item-header-avatar -->
			<?php endif; ?>

			<div id="item-header-content">

				<div id="item-buttons"><?php

					/**
					 * Fires in the group header actions section.
					 *
					 * @since 1.2.6
					 */
					do_action( 'bp_group_header_actions' ); ?></div><!-- #item-buttons -->

				<?php

				/**
				 * Fires before the display of the group's header meta.
				 *
				 * @since 1.2.0
				 */
				do_action( 'bp_before_group_header_meta' ); ?>

				<div id="item-meta">

					<?php

					/**
					 * Fires after the group header actions section.
					 *
					 * @since 1.2.0
					 */
					do_action( 'bp_group_header_meta' ); ?>

					<span class="highlight"><?php bp_group_type(); ?></span>
					<span class="activity"><?php printf( __( 'active %s', 'ap3-ion-theme' ), bp_get_group_last_active() ); ?></span>

					<?php bp_group_description(); ?>

				</div>
			</div><!-- #item-header-content -->

			</div><!-- .item -->

		</div><!-- #item-header-cover-image -->
	</div><!-- #header-cover-image -->
</div><!-- #cover-image-container -->

<?php

/**
 * Fires after the display of a group's header.
 *
 * @since 1.2.0
 */
do_action( 'bp_after_group_header' );

/** This action is documented in bp-templates/bp-legacy/buddypress/activity/index.php */
do_action( 'template_notices' ); ?>
