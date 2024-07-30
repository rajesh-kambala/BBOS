using System;
using Xamarin.Forms.Platform.iOS;
using Xamarin.Forms;
using UIKit;
using BBOSMobile.Forms.CustomRenderers;
using BBOSMobile.iOS.CustomRenderers;

[assembly: ExportRenderer (typeof (CustomEntry), typeof (CustomEntryRenderer))]

namespace BBOSMobile.iOS.CustomRenderers
{
	public class CustomEntryRenderer : EntryRenderer
	{
		// Override the OnElementChanged method so we can tweak this renderer post-initial setup
		protected override void OnElementChanged (ElementChangedEventArgs<Entry> e)
		{
			base.OnElementChanged (e);

			if (Control != null) {   // perform initial setup
				// do whatever you want to the UITextField here!
				Control.BackgroundColor = UIColor.White;
				Control.Layer.CornerRadius = 1f;
				Control.Layer.BorderWidth = 1;
				Control.Layer.BorderColor = Color.Gray.ToCGColor();
				//Control.BorderStyle = UITextBorderStyle.Line;

				if(this.TraitCollection.UserInterfaceStyle == UIUserInterfaceStyle.Dark)
				{
					this.Control.TextColor = UIColor.LightTextColor;
					this.Control.BackgroundColor = UIColor.DarkTextColor;
				}
				else if (this.TraitCollection.UserInterfaceStyle == UIUserInterfaceStyle.Light)
				{
					this.Control.TextColor = UIColor.DarkTextColor;
					this.Control.BackgroundColor = UIColor.LightTextColor;
				}
			}
		}
	}
}

