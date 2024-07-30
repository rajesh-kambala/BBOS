using System;
using BBOSMobile.Core.Managers;
using BBOSMobile.Core.Models;
using System.Collections.Generic;
using System.Linq;
using System.Collections.ObjectModel;

namespace BBOSMobile.Forms.ViewModels
{
	public class CompanySurveyViewModel : BaseViewModel
	{
		public CompanySurveyViewModel ()
		{
			SelectedTradePractice = new TradePractice() { TradePracticeID = -1, Definition = "Trade Practice" ,Code = ""};
			SelectedPayPerformance = new PayPerformance() { PayPerformanceID = -1, Definition = "Pay Performance" , Code = ""};
			SelectedHighCredit = new HighCredit() { HighCreditID = -1, Definition = "High Credit" , Code = ""};
			SelectedLastDealt = new LastDealt() { LastDealtID = -1, Definition = "Last Dealt" , Code= ""};
			SelectedOutOfBusiness = new OutOfBusiness() { OutOfBusinessID = -1, Definition = "Out Of Business", Value=false};



        }

		public enum Selection
		{
			None,
			TradePractice,
			PayPerformance,
			HightCredit,
			LastDealt,
			OutOfBusiness,
		}

		//Which dropdown did they select on the search page
		public Selection SelectedDropdown {get;set;}

		//Standard text fields
		public string CompanyName {get;set;}
		public string BBNumber {get;set;}
		public string City {get;set;}
		public string Zip {get;set;}


		//The dropdown item lists
		public List<TradePractice> TradePractices { get; set; }
		public List<PayPerformance> PayPerformances { get; set; }
		public List<HighCredit> HighCredits { get; set; }
		public List<LastDealt> LastDealts { get; set; }
		public List<OutOfBusiness> OutOfBusinesses { get; set; }


		public const string SelectedTracePracticePropertyName = "SelectedTradePractice";
		private TradePractice selectedTradePractice = new TradePractice() { TradePracticeID = -1, Definition = "Trade Practice"};
		public TradePractice SelectedTradePractice
		{
			get { return selectedTradePractice; }
			set { SetProperty(ref selectedTradePractice, value, SelectedTracePracticePropertyName); }
		}


		public const string SelectedPayPerformancePropertyName = "SelectedPayPerformance";
		private PayPerformance selectedPayPerformance = new PayPerformance() { PayPerformanceID = -1, Definition = "Pay Performance"};
		public PayPerformance SelectedPayPerformance
		{
			get { return selectedPayPerformance; }
			set { SetProperty(ref selectedPayPerformance, value, SelectedPayPerformancePropertyName); }
		}


		public const string SelectedHighCreditPropertyName = "SelectedHighCredit";
		private HighCredit selectedHighCredit = new HighCredit() { HighCreditID = -1, Definition = "High Credit"};
		public HighCredit SelectedHighCredit
		{
			get { return selectedHighCredit; }
			set { SetProperty(ref selectedHighCredit, value, SelectedHighCreditPropertyName); }
		}

		public const string SelectedLastDealtPropertyName = "SelectedLastDealt";
		private LastDealt selectedLastDealt = new LastDealt() { LastDealtID = -1, Definition = "Last Dealt"};
		public LastDealt SelectedLastDealt
		{
			get { return selectedLastDealt; }
			set { SetProperty(ref selectedLastDealt, value, SelectedLastDealtPropertyName); }
		}

		public const string SelectedOutOfBusinessPropertyName = "SelectedOutOfBusiness";
		private OutOfBusiness selectedOutOfBusiness = new OutOfBusiness() { OutOfBusinessID = -1, Definition = "Out Of Business"};
		public OutOfBusiness SelectedOutOfBusiness
		{
			get { return selectedOutOfBusiness; }
			set { SetProperty(ref selectedOutOfBusiness, value, SelectedOutOfBusinessPropertyName); }
		}


		public int PageSize {get;set;}
		public int PageIndex {get;set;}
		public ObservableCollection<CompanyListItemViewModel> Companies { get; set; }

		public bool IsLumber {get;set;}



	}
	/*
	public class EnumPlaceholder{
		public int Id {get;set;}
		public string Definition {get;set;}
	}
	*/
}

