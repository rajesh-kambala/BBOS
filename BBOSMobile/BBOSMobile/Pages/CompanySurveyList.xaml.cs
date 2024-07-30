using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Managers;
using System.Linq;
using System.Text.RegularExpressions;
using Xamarin.Forms.Xaml;

namespace BBOSMobile.Forms
{
	[XamlCompilation(XamlCompilationOptions.Compile)]
	public partial class CompanySurveyList : BaseContentPage
	{
		CompanySurveyViewModel viewModel;

		public CompanySurveyList (CompanySurveyViewModel vm)
		{
			InitializeComponent ();
			viewModel = vm;
			SetBindingSourceAndLists ();
			this.BindingContext = viewModel;

			listViewOptions.ItemSelected += listViewOptions_ItemSelected;
		}

	

		private void SetBindingSourceAndLists(){
			//Load up our lists from the database, and set the items source for the list the user
			//will select from

			//var bbosDataManager = new BBOSDataManager ();

            if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.TradePractice) {

				//manually insert values into these lists for now

				/*
				var list = GetList<BBOSMobile.ServiceModels.Common.Enumerations.IndustryType>();
				//removing lumber because of produce user
				list.Remove(list[3]);
				listViewOptions.ItemsSource = list;
				*/
				var list = TradePractice.getList();
				listViewOptions.ItemsSource = list;


			}

            else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.HightCredit)
            {

				var list = HighCredit.getList();
				listViewOptions.ItemsSource = list;


			}
            else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.LastDealt)
            {
				var list = LastDealt.getList();
				listViewOptions.ItemsSource = list;


			}
			else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.PayPerformance)
			{

				var list = PayPerformance.getList();
				listViewOptions.ItemsSource = list;


			}
			else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.OutOfBusiness)
			{

				var list = OutOfBusiness.getList();
				listViewOptions.ItemsSource = list;

			}
			
		}

		void listViewOptions_ItemSelected (object sender, SelectedItemChangedEventArgs e)
		{
			//Based on the dropdown, choose the appropriate type to cast the item to
            if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.HightCredit) 
			{
				CompanySurvey.ViewModel.SelectedHighCredit = e.SelectedItem as HighCredit;
				//viewModel.SelectedIndustry = e.SelectedItem as EnumPlaceholder;

			}

            else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.LastDealt)
            {
				CompanySurvey.ViewModel.SelectedLastDealt = e.SelectedItem as LastDealt;
                //viewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
            }
            else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.OutOfBusiness)
            {
				CompanySurvey.ViewModel.SelectedOutOfBusiness = e.SelectedItem as OutOfBusiness;
                //viewModel.SelectedState = e.SelectedItem as State;
            }
			else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.PayPerformance)
			{
				CompanySurvey.ViewModel.SelectedPayPerformance = e.SelectedItem as PayPerformance;
				//viewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
			}
			else if (viewModel.SelectedDropdown == CompanySurveyViewModel.Selection.TradePractice)
			{
				CompanySurvey.ViewModel.SelectedTradePractice = e.SelectedItem as TradePractice;
				//viewModel.SelectedState = e.SelectedItem as State;
			}
			//Now go back to the previous page, with our new info
			Navigation.PopAsync ();

		}


		//Convert an enum list to a list of my enum placeholder class
		public static List<EnumPlaceholder> GetList<T>() where T : struct
		{
			List<EnumPlaceholder> epl = new List<EnumPlaceholder> ();
			foreach (int e in Enum.GetValues(typeof(T)))
			{
				EnumPlaceholder item = new EnumPlaceholder();
				item.Id = e;
				item.Definition = CamelCaseToSpaces(Enum.GetName(typeof(T), e));
				epl.Add (item);
			}
			return epl;

		}

		public static string ReplaceLeadingUnderScore(string value){
			return Regex.Replace (value, "_", "");
		}
		public static string ReplaceDoubleUnderScoreSpace(string value){
			return Regex.Replace (value, "__", " ");
		}
		public static string ReplacePlusWordWithSign(string value){
			return Regex.Replace (value, "plussign", "+");
		}
		public static string ReplaceMilWithM(string value){
			return Regex.Replace (value, "mil", "M ");
		}

		//Convert camel cased enum to strings with spaces
		public static string CamelCaseToSpaces(string value)
		{
			value = ReplaceDoubleUnderScoreSpace (value);
			value = ReplaceLeadingUnderScore (value);
			value = ReplacePlusWordWithSign (value);
			value = Regex.Replace(value, "(?!^)([A-Z])", " $1");
			value = ReplaceMilWithM (value);
			return value;
		}




	}




}

