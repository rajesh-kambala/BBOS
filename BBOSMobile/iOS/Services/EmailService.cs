using System.Collections.Generic;

using MessageUI;
using UIKit;
using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.iOS;
using BBOSMobile.iOS.Services;
using System;
using System.Linq;

[assembly: Dependency(typeof(EmailService))]
namespace BBOSMobile.iOS.Services
{
	public class EmailService : IEmailService
	{
		/// <summary>
		/// Used for registration with dependency service
		/// </summary>
		public static void Init ()
		{
		}

		/// <summary>
		/// Opens up the ios Email Controller with pre-populated values
		/// </summary>
		/// <param name="email">Email.</param>
		public void CreateEmail(Email email )
		{
			if (MFMailComposeViewController.CanSendMail) 
			{
				var mailController = new MFMailComposeViewController ();
				mailController.SetMessageBody (email.Body, false);
				mailController.SetSubject (email.Subject);	
				mailController.SetToRecipients (email.ToAddresses.ToArray ());
				mailController.Finished += ( s, args) => args.Controller.DismissViewController (true, null);
                //var rootViewController = UIApplication.SharedApplication.KeyWindow.RootViewController;
                var rootViewController = GetCurrentUIController();

                rootViewController.PresentViewController (mailController, true, null);
			}
		}
		public bool CanSendEmail(){
			return MFMailComposeViewController.CanSendMail;
		}

        public static UIViewController GetCurrentUIController()
        {
            UIViewController viewController;
            var window = UIApplication.SharedApplication.KeyWindow;
            if (window == null)
            {
                throw new InvalidOperationException("There's no current active window");
            }

            if (window.RootViewController.PresentedViewController == null)
            {
                window = UIApplication.SharedApplication.Windows
                            .First(i => i.RootViewController != null &&
                                        i.RootViewController.GetType().FullName
                                        .Contains(typeof(Xamarin.Forms.Platform.iOS.Platform).FullName));
            }

            viewController = window.RootViewController;

            while (viewController.PresentedViewController != null)
            {
                viewController = viewController.PresentedViewController;
            }

            return viewController;
        }
    }
}


