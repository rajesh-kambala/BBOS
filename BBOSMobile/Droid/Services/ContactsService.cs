
using Android.Content;


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

using BBOSMobile.Core.Interfaces;
using BBOSMobile.Droid.Services;
using Xamarin.Forms;
using Android.Provider;

[assembly: Dependency(typeof(ContactsService))]
namespace BBOSMobile.Droid.Services
{
    public class ContactsService : IContactsService
    {

        public static void Init() { }
        public void CreateContact(String[] ContactInfo)
        {

            var full_name = ContactInfo[0] + " " + ContactInfo[1];


            var intent = new Intent(Intent.ActionInsert);
            intent.SetType(ContactsContract.Contacts.ContentType);
            intent.PutExtra(ContactsContract.Intents.Insert.Name, full_name);
            intent.PutExtra(ContactsContract.Intents.Insert.Email, ContactInfo[2]);
            intent.PutExtra(ContactsContract.Intents.Insert.Phone, ContactInfo[3]);
            intent.PutExtra(ContactsContract.Intents.Insert.Company, ContactInfo[4]);
            intent.PutExtra(ContactsContract.Intents.Insert.JobTitle, ContactInfo[5]);


            Android.App.Application.Context.StartActivity(intent);


        }

     


        
        public bool CanCreateContact()
            {
                return true;
            }


    }
}

