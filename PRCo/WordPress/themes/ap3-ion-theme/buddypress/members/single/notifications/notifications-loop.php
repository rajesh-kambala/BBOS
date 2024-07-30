<div class="notifications">

	<h2 class="title"><?php _e( 'Notifications', 'ap3-ion-theme' ); ?></h2>

	<ul class="list">
		<?php while ( bp_the_notifications() ) : bp_the_notification(); ?>
		<li class="item">
			<?php bp_the_notification_description();  ?>
			
			<div class="actions">
				<?php bp_the_notification_action_links(); ?>
			</div>
		</li>

	<?php endwhile; ?>

	</ul>

</div>
