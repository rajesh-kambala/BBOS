using System;

using Xamarin.Forms;

namespace BBOSMobile.Forms.Custom
{
	public class MenuItem<T> : MenuItem
	{
	}

	public class MenuItem
	{
		public string Title { get; set; }
		public int Count { get; set; }
		public bool Selected { get; set; }
		public string Padding { get; set;}
		public virtual string Icon { get { return 
				Title.ToLower() + ".png" ; } }
		public ImageSource IconSource { get { return ImageSource.FromFile(Icon); } }
		public Thickness paddingThickness {get; set; }
	}
}


