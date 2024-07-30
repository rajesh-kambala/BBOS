using Xamarin.Forms.Platform.Android;
using Xamarin.Forms;
using BBOSMobile.Forms.CustomRenderers;
using BBOSMobile.Droid.CustomRenderers;

[assembly: ExportRenderer(typeof(CustomEditor), typeof(CustomEditorRenderer))]

namespace BBOSMobile.Droid.CustomRenderers
{
    public class CustomEditorRenderer : EditorRenderer
	{
		// Override the OnElementChanged method so we can tweak this renderer post-initial setup
		protected override void OnElementChanged (ElementChangedEventArgs<Editor> e)
		{
			base.OnElementChanged (e);

			if (Control != null) {
				// do whatever you want to the textField here!
				var nativeEditText = (global::Android.Widget.EditText)Control;
				// do whatever you want to the EditText here!

				//nativeEditText.SetBackgroundColor (global::Android.Graphics.Color.DarkGray);
				nativeEditText.SetBackgroundColor(global::Android.Graphics.Color.White);
				nativeEditText.SetTextColor(global::Android.Graphics.Color.Black);

			}
		}
	}
}



