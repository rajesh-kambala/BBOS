<?php

/**
 * BuddyPress - Activity Stream (Single Item)
 *
 * This template is used by activity-loop.php and AJAX functions to show
 * each activity.
 *
 * @package BuddyPress
 * @subpackage bp-legacy
 */

?>

<?php do_action( 'bp_before_activity_entry' ); ?>

<li class="item entry-single item-text-wrap <?php bp_activity_css_class(); ?>" id="activity-<?php bp_activity_id(); ?>">
	<div class="activity-avatar">
		<a class="avatar" href="<?php bp_activity_user_link(); ?>">

			<?php bp_activity_avatar('type=thumb'); ?>

		</a>
	</div>

	<div class="activity-content">

		<div class="activity-header">

			<?php bp_activity_action(); ?>

		</div>

		<?php if ( bp_activity_has_content() ) : ?>

			<div class="activity-inner">

				<?php bp_activity_content_body(); ?>

			</div>

		<?php endif; ?>

		<?php do_action( 'bp_activity_entry_content' ); ?>

		<div class="activity-meta">

			<?php if ( bp_get_activity_type() == 'activity_comment' ) : ?>

				<a href="<?php bp_activity_thread_permalink(); ?>" class="bp-secondary-action ajaxify" title="<?php esc_attr_e( 'View Conversation', 'ap3-ion-theme' ); ?>"><?php _e( 'View Conversation', 'ap3-ion-theme' ); ?></a>

			<?php endif; ?>

			<?php if ( is_user_logged_in() ) : ?>

				<?php if ( bp_activity_can_comment() ) : ?>

					<a href="<?php bp_activity_comment_link(); ?>" class="acomment-reply bp-primary-action" id="acomment-comment-<?php bp_activity_id(); ?>"><i class="icon ion-ios-chatbubble-outline"><span class="comment-count"><?php if (bp_activity_get_comment_count() > 0 ) echo bp_activity_get_comment_count(); ?></span></i></a>

				<?php endif; ?>

				<?php if ( bp_activity_can_favorite() ) : ?>

					<?php if ( !bp_get_activity_is_favorite() ) : ?>

						<a href="<?php bp_activity_favorite_link(); ?>" class="fav bp-secondary-action ajaxify" title="<?php esc_attr_e( 'Mark as Favorite', 'ap3-ion-theme' ); ?>"><i class="icon ion-ios-star-outline"></i></a>

					<?php else : ?>

						<a href="<?php bp_activity_unfavorite_link(); ?>" class="unfav bp-secondary-action ajaxify" title="<?php esc_attr_e( 'Remove Favorite', 'ap3-ion-theme' ); ?>"><i class="icon ion-ios-star"></i></a>

					<?php endif; ?>

				<?php endif; ?>

				<?php if ( bp_activity_user_can_delete() ) bp_activity_delete_link(); ?>

				<?php do_action( 'bp_activity_entry_meta' ); ?>

			<?php endif; ?>

		</div>

	</div>

	<?php do_action( 'bp_before_activity_entry_comments' ); ?>

	<?php if ( ( is_user_logged_in() && bp_activity_can_comment() ) || bp_is_single_activity() ) : ?>

		<div class="activity-comments">

			<?php bp_activity_comments(); ?>

			<?php if ( is_user_logged_in() ) : ?>

				<form action="<?php bp_activity_comment_form_action(); ?>" method="post" id="ac-form-<?php bp_activity_id(); ?>" class="ac-form list"<?php bp_activity_comment_form_nojs_display(); ?>>
					
					<div class="ac-reply-content">
						<div class="ac-textarea">
							<label class="item item-input">
							<textarea id="ac-input-<?php bp_activity_id(); ?>" class="ac-input" name="ac_input_<?php bp_activity_id(); ?>"></textarea>
							</label>
						</div>
						<div>
							<input type="submit" class="button button-primary" name="ac_form_submit" value="<?php esc_attr_e( 'Post', 'ap3-ion-theme' ); ?>" /> 
							<a href="#" class="button button-secondary ac-reply-cancel"><?php _e( 'Cancel', 'ap3-ion-theme' ); ?></a>
						</div>
						<input type="hidden" name="comment_form_id" value="<?php bp_activity_id(); ?>" />
					</div>

					<?php do_action( 'bp_activity_entry_comments' ); ?>

					<?php wp_nonce_field( 'new_activity_comment', '_wpnonce_new_activity_comment' ); ?>

				</form>

			<?php endif; ?>

		</div>

	<?php endif; ?>

	<?php do_action( 'bp_after_activity_entry_comments' ); ?>

	<!-- <a href="<?php bp_activity_comment_link(); ?>" class="acomment-reply bp-primary-action button button-block button-secondary" id="acomment-comment-<?php bp_activity_id(); ?>">Reply</a> -->

</li>

<?php do_action( 'bp_after_activity_entry' ); ?>
