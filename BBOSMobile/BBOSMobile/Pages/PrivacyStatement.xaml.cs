using System;
using System.Linq;

using Xamarin.Forms;
using BBOSMobile.Core.Managers;

namespace BBOSMobile.Forms.Pages
{
	public partial class PrivacyStatement : BaseContentPage
	{
		public PrivacyStatement ()
		{
			InitializeComponent ();
			LoadPrivacyStatement ();
			Title = "Privacy Statement";
		}

		private void LoadPrivacyStatement()
		{
			var bbosDataManager = new BBOSDataManager ();

			//For now assume there is only one row in this table
			var privacyStatement = bbosDataManager.GetAllItems<BBOSMobile.Core.Models.PrivacyStatement> ().FirstOrDefault ();
			if (privacyStatement == null) 
			{
				//Add some placeholder text
				privacyStatement = new BBOSMobile.Core.Models.PrivacyStatement ();
				privacyStatement.PrivacyStatementText = "Privacy statement placeholder text";
				privacyStatement.PrivacyStatementDate = DateTime.Now;
				bbosDataManager.SaveItem (privacyStatement);
			}

			lblPrivacyStatement.Text = privacyStatement.PrivacyStatementText;

		}
	}
}

