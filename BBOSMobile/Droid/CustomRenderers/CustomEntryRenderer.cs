using Xamarin.Forms.Platform.Android;
using Xamarin.Forms;
using BBOSMobile.Forms.CustomRenderers;
using BBOSMobile.Droid.CustomRenderers;
using Android.Graphics.Drawables;
using Android.Graphics.Drawables.Shapes;
using Android.Graphics;

[assembly: ExportRenderer(typeof(CustomEntry), typeof(CustomEntryRenderer))]

namespace BBOSMobile.Droid.CustomRenderers
{
    public class CustomEntryRenderer : EntryRenderer
	{
		// Override the OnElementChanged method so we can tweak this renderer post-initial setup
		protected override void OnElementChanged (ElementChangedEventArgs<Entry> e)
		{
			base.OnElementChanged (e);

			if (Control != null) {
				// do whatever you want to the textField here!
				var nativeEditText = (global::Android.Widget.EditText)Control;
				// do whatever you want to the EditText here!

				//nativeEditText.SetBackgroundColor (global::Android.Graphics.Color.DarkGray);
				nativeEditText.SetBackgroundColor(global::Android.Graphics.Color.White);
				nativeEditText.SetTextColor(global::Android.Graphics.Color.Black);
				//Control.SetBackgroundColor(global::Android.Graphics.Color.White);
				var shape = new ShapeDrawable(new RectShape());
				shape.Paint.Color = global::Android.Graphics.Color.Black;
				shape.Paint.StrokeWidth = 2;
				shape.Paint.SetStyle(Paint.Style.Stroke);

				nativeEditText.SetBackgroundDrawable(shape);

			}
		}
	}
}

