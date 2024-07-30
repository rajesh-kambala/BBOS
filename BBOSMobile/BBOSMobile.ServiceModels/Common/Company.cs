using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;


namespace BBOSMobile.ServiceModels.Common
{
    public class Company: CompanyBase
    {
        public string BlueBookScore { get; set; }

        public string Status { get; set; }

        public string TollFree { get; set; }

        public string Fax { get; set; }

        public string Email { get; set; }

        public string Web { get; set; }

        public IEnumerable<SocialMedia> SocialMedia { get; set; }

        public string CreditWorthRating { get; set; }

        public string RatingKeyNumbers { get; set; }

        public string PayIndicator { get; set; }

		public IEnumerable<Classification> Classifications { get; set; }

		public IEnumerable<Commodity> Commodities { get; set; }

		public IEnumerable<Product> Products { get; set; }

		public IEnumerable<Service> Services { get; set; }

		public IEnumerable<Specie> Species { get; set; }

		public int CurrentPayReports { get; set; }

		public IEnumerable<Contact> Contacts { get; set; }

		public IEnumerable<Note> Notes { get; set; }

		public string Listing { get; set; }

		public ObservableCollection<Rating> Ratings { get; set; }

		public bool IsLocalSource { get; set; }

        public bool IsWatchDog { get; set; }
    }
}
