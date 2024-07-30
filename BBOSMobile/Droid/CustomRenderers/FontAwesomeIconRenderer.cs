
using Android.Graphics;
using Xamarin.Forms;
using Xamarin.Forms.Platform.Android;
using BBOSMobile.Forms.CustomRenderers;
using BBOSMobile.Droid.CustomRenderers;

[assembly: ExportRenderer(typeof(FontAwesomeIcon), typeof(FontAwesomeIconRenderer))]
namespace BBOSMobile.Droid.CustomRenderers
{
    /// <summary>
    /// Add the FontAwesome.ttf to the Assets folder and mark as "Android Asset"
    /// </summary>
    public  class FontAwesomeIconRenderer : LabelRenderer
	{
		protected override void OnElementChanged (ElementChangedEventArgs<Label> e)
		{
			base.OnElementChanged (e);
			Control.Typeface = Typeface.CreateFromAsset (Xamarin.Forms.Forms.Context.Assets, FontAwesomeIcon.Typeface + ".ttf");
			if (e.OldElement == null)
			{
				//The ttf in /Assets is CaseSensitive, so name it FontAwesome.ttf

			}
		}
	}
}

