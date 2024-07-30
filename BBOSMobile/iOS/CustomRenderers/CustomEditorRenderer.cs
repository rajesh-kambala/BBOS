using System;
using Xamarin.Forms.Platform.iOS;
using Xamarin.Forms;
using UIKit;
using BBOSMobile.Forms.CustomRenderers;
using BBOSMobile.iOS.CustomRenderers;

[assembly: ExportRenderer (typeof (CustomEditor), typeof (CustomEditorRenderer))]

namespace BBOSMobile.iOS.CustomRenderers
{
	public class CustomEditorRenderer : EditorRenderer
	{
		// Override the OnElementChanged method so we can tweak this renderer post-initial setup
		protected override void OnElementChanged (ElementChangedEventArgs<Editor> e)
		{
			base.OnElementChanged (e);

			if (Control != null) {   // perform initial setup
				// do whatever you want to the UITextField here!
//				Control.BackgroundColor = UIColor.White;
//				Control.TextColor = UIColor.Black;
				//Control.BorderStyle = UITextBorderStyle.Line;
			}
		}
	}
}



