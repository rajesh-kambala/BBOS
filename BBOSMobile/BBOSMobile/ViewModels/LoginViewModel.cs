using System;

namespace BBOSMobile.Forms.ViewModels
{
	public class LoginViewModel : BaseViewModel
	{

        public const string VersionPropertyName = "Version";
        public const string EmailPropertyName = "Email";
		private string email = string.Empty;
        private string version = string.Empty;
        public string Email
		{
			get { return email; }
			set { SetProperty(ref email, value, EmailPropertyName); }
		}
        public string Version
        {
            get { return version; }
            set { SetProperty(ref version, value, VersionPropertyName); }
        }

        public const string PasswordPropertyName = "Password";
		private string password = string.Empty;
		public string Password
		{
			get { return password; }
			set { SetProperty(ref password, value, PasswordPropertyName); }
		}
	}
}

