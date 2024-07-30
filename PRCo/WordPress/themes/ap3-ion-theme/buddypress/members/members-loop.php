<?php if ( bp_has_members( bp_ajax_querystring( 'members' ) ) ) : ?>

	<!--div id="pag-top" class="pagination">

		<div class="pagination-links" id="member-dir-pag-top">

			<?php bp_members_pagination_links(); ?>

		</div>

	</div-->


	<ul id="members-list" class="list" role="main">

	<?php while ( bp_members() ) : bp_the_member(); ?>

		<li class="item">
			<a class="member-avatar" href="<?php bp_member_permalink(); ?>"><?php bp_member_avatar(); ?></a>

				<h2 class="item-title">
					<a href="<?php bp_member_permalink(); ?>"><?php bp_member_name(); ?></a>
				</h2>

				<div class="item-meta"><span class="activity"><?php bp_member_last_active(); ?></span></div>

				<?php do_action( 'bp_directory_members_item' ); ?>

				<?php
				 /***
				  * If you want to show specific profile fields here you can,
				  * but it'll add an extra query for each member in the loop
				  * (only one regardless of the number of fields you show):
				  *
				  * bp_member_profile_data( 'field=the field name' );
				  */
				?>

			<div class="action">

				<?php do_action( 'bp_directory_members_actions' ); ?>

			</div>

			<div class="clear"></div>
		</li>

	<?php endwhile; ?>

	</ul>

	<?php bp_member_hidden_fields(); ?>

	<div id="pag-bottom" class="pagination">

		<div class="pagination-links" id="member-dir-pag-bottom">

			<?php bp_members_pagination_links(); ?>

		</div>

	</div>

<?php else: ?>

	<div id="message" class="info">
		<p><?php _e( "Sorry, no members were found.", 'ap3-ion-theme' ); ?></p>
	</div>

<?php endif; ?>
