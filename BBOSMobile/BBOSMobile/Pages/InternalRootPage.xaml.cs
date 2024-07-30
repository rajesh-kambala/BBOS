using System;
using System.Collections.Generic;

using Xamarin.Forms;

namespace BBOSMobile.Forms.Pages
{
	public partial class InternalRootPage : TabbedPage
	{
		private bool tabAvail = true;
		public InternalRootPage ()
		{
			
				InitializeComponent ();
			
				this.CurrentPageChanged += (object sender, EventArgs e) => {
					var tabbedPage = (InternalRootPage) sender;
					Title =  ((Page) tabbedPage.CurrentPage).Title;
				};

		}
	}
}

