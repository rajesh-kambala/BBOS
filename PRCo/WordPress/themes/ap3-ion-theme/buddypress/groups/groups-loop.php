<?php if ( bp_has_groups( bp_ajax_querystring( 'groups' ) ) ) : ?>

	<ul id="groups-list" class="item-list list" role="main">

	<?php while ( bp_groups() ) : bp_the_group(); ?>

		<li <?php bp_group_class(); ?>>
			<div class="item">
				<a class="avatar" href="<?php bp_group_permalink(); ?>"><?php bp_group_avatar( 'type=thumb&width=50&height=50' ); ?></a>
			

				<div class="item-title"><a href="<?php bp_group_permalink(); ?>"><?php bp_group_name(); ?></a></div>
				<div class="item-meta"><span class="activity"><?php printf( __( 'active %s', 'ap3-ion-theme' ), bp_get_group_last_active() ); ?></span></div>

				<div class="item-desc"><?php bp_group_description_excerpt(); ?></div>

				<?php do_action( 'bp_directory_groups_item' ); ?>


				<div class="action">

					<?php do_action( 'bp_directory_groups_actions' ); ?>

				</div>
				<div class="meta right">
					<?php bp_group_type(); ?> / <?php bp_group_member_count(); ?>
				</div>

			</div>
		</li>

	<?php endwhile; ?>

	</ul>

	<div id="pag-bottom" class="pagination">

		<div class="pagination-links" id="group-dir-pag-bottom">

			<?php bp_groups_pagination_links(); ?>

		</div>

	</div>

<?php else: ?>

	<div id="message" class="info">
		<p><?php _e( 'There were no groups found.', 'ap3-ion-theme' ); ?></p>
	</div>

<?php endif; ?>
