using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Contacts;
using ContactsUI;
using Foundation;
using UIKit;
using MessageUI;
using Xamarin.Forms;
using BBOSMobile.Core;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using BBOSMobile.iOS;
using BBOSMobile.iOS.Services;
using System.Diagnostics;
using CoreGraphics;

[assembly: Dependency(typeof(ContactsService))]
namespace BBOSMobile.iOS.Services
{
    public class ContactsService:IContactsService
    {
        public static void Init() { }
        public void CreateContact(String[] ContactInfo) {

            

            var store = new CNContactStore();

            var contact = new CNMutableContact();
            contact.ContactType = CNContactType.Person;
            contact.GivenName = ContactInfo[0];
            contact.FamilyName = ContactInfo[1];


            var email_address = new CNLabeledValue<NSString>(CNLabelKey.Work,new NSString(ContactInfo[2]));
            contact.EmailAddresses = new CNLabeledValue<NSString>[] { email_address }; ;

            ///var phone_number = new CNLabeledValue<CNPhoneNumber>(CNLabelPhoneNumberKey.Main, new CNPhoneNumber(ContactInfo[3]));

            var phone_number = new CNLabeledValue<CNPhoneNumber>(CNLabelKey.Work, new CNPhoneNumber(ContactInfo[3]));

            contact.PhoneNumbers = new CNLabeledValue<CNPhoneNumber>[] { phone_number };
            contact.OrganizationName = ContactInfo[4];

            contact.JobTitle = ContactInfo[5];

            Debug.WriteLine("*****before CNSaveRequest");


            CNSaveRequest cNSave = new CNSaveRequest();

            Debug.WriteLine("*****before CNSaveRequest.AddContact");

            cNSave.AddContact(contact,null);

            Debug.WriteLine("*****before CNSaveRequest.AddContact");

            NSError nSError = new NSError();

            Debug.WriteLine("*****before ExecuteSaveRequest");

            store.ExecuteSaveRequest(cNSave,out nSError);

            Debug.WriteLine("*****after ExecuteSaveRequest");

            string message = "not set";

            if(nSError == null)
            {
                message = "'" + contact.GivenName + " " + contact.FamilyName + "' Was Added";

                

            }
            else
            {
                message = "Contacts Cannot Be Added At This Time";
            }




            

            //Create Alert
            var okAlertController = UIAlertController.Create("Contact", message, UIAlertControllerStyle.Alert);

                //Add Action
                okAlertController.AddAction(UIAlertAction.Create("OK", UIAlertActionStyle.Default, null));

                // Present Alert
               GetCurrentUIController().PresentViewController(okAlertController, true, null);


            //this is null?   Debug.WriteLine("*****Contact Save Error:" + nSError.Description);
            

            /*

            var editor = CNContactViewController.FromNewContact(contact);
            // Configure editor
            editor.ContactStore = store;
            editor.AllowsActions = true;
            editor.AllowsEditing = true;
            
            editor.Delegate = new ContactDelegate();

            //CNContactViewController cNContactViewController = CNContactViewController.FromNewContact(contact);
            //GetCurrentUIController().PresentViewController(cNContactViewController, true, null);

            editor.LoadViewIfNeeded();
            //cNContactViewController.SetEditing(true, true);
            

            //UINavigationController navcontroller = new UINavigationController(cNContactViewController);
            //GetCurrentUIController().ShowViewController(cNContactViewController, null);

            GetCurrentUIController().PresentViewController(editor, true, null);


            */


            /*

            var editor = CNContactViewController.FromNewContact(contact);
            // Configure editor
            editor.ContactStore = store;
            editor.AllowsActions = true;
            editor.AllowsEditing = true;
            editor.Delegate = new ContactDelegate();



            //var rootViewController = UIApplication.SharedApplication.KeyWindow.RootViewController;//works when you dont have to log in
            var rootViewController = GetCurrentUIController();

            UINavigationController navcontroller = new UINavigationController(editor);

            /*
            if (UIKit.UIDevice.CurrentDevice.UserInterfaceIdiom != UIUserInterfaceIdiom.Pad)
            {
            */
            //rootViewController.ShowViewController(navcontroller, null); //for phones
            /*}
            else
            {*/


            //try
            //{
            //rootViewController.PresentViewController(navcontroller, true, null); //for ipads and small phones

            //}
            //catch(Exception ex)
            //{

            //Debug.WriteLine("*****present contacts failed so now trying to just show existing UI window");

            //rootViewController.ShowViewController(navcontroller, null); //for big phones
            //}
            //       rootViewController.PresentViewController(navcontroller, true, null); //for ipads
            //}


            //rootViewController.PresentViewController(editor, true, null);





            //dereks email style way
            //var rootViewController = UIApplication.SharedApplication.KeyWindow.RootViewController;
            //rootViewController.PresentViewController(editor, true, null);



            //ipad
            //var rootViewController = UIApplication.SharedApplication.KeyWindow.RootViewController;
            //UINavigationController navcontroller = new UINavigationController(editor);
            //rootViewController.PresentViewController(navcontroller, true, null);




            //var navController = rootViewController as UINavigationController;
            //var navController = rootViewController as UINavigationController;
            //navController.PushViewController(editor, true);

            /*
            var saveRequest = new CNSaveRequest();
            saveRequest.AddContact(contact, store.DefaultContainerIdentifier);

            NSError error;
            if (store.ExecuteSaveRequest(saveRequest, out error))
            {
                Console.WriteLine("New contact saved");
            }
            else
            {
                Console.WriteLine("Save error: {0}", error);
            }

            */


            /* this works on an ipad
            var rootViewController = UIApplication.SharedApplication.KeyWindow.RootViewController;
            UINavigationController navcontroller = new UINavigationController(editor);
            rootViewController.PresentViewController(navcontroller, true, null);

                */


        }
        public bool CanCreateContact()
        {
        return true;
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

class ContactDelegate : CNContactViewControllerDelegate
{
public override void DidComplete(CNContactViewController viewController, CNContact contact)
{
//if (contact == null)
    viewController.DismissViewController(true, null);
}
}

}



