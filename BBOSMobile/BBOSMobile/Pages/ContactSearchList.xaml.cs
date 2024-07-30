using System;
using System.Collections.Generic;

using Xamarin.Forms;
using BBOSMobile.Forms.ViewModels;
using BBOSMobile.Forms.Pages;
using BBOSMobile.Core.Models;
using BBOSMobile.Core.Managers;
using System.Linq;
using System.Text.RegularExpressions;



namespace BBOSMobile.Forms
{
	public partial class ContactSearchList : BaseContentPage
	{
		ContactSearchViewModel viewModel;

		public ContactSearchList (ContactSearchViewModel vm)
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

			var bbosDataManager = new BBOSDataManager ();

            if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.Industry) {
				var list = GetList<BBOSMobile.ServiceModels.Common.Enumerations.IndustryType>();
				//removing lumber because of produce user
				list.Remove(list[3]);
				listViewOptions.ItemsSource = list;
			}

            else if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.State)
            {
                viewModel.States = bbosDataManager.GetAllItems<State>().ToList();
                listViewOptions.ItemsSource = viewModel.States;
            }
            else if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.Radius)
            {
                listViewOptions.ItemsSource = GetList<BBOSMobile.ServiceModels.Common.Enumerations.Radius>();
            }
        }

		void listViewOptions_ItemSelected (object sender, SelectedItemChangedEventArgs e)
		{
			//Based on the dropdown, choose the appropriate type to cast the item to
            if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.Industry) 
			{
				ContactSearch.ViewModel.SelectedIndustry = e.SelectedItem as EnumPlaceholder;
				//viewModel.SelectedIndustry = e.SelectedItem as EnumPlaceholder;

			}

            else if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.Radius)
            {
                ContactSearch.ViewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
                //viewModel.SelectedRadius = e.SelectedItem as EnumPlaceholder;
            }
            else if (viewModel.SelectedDropdown == ContactSearchViewModel.Selection.State)
            {
                ContactSearch.ViewModel.SelectedState = e.SelectedItem as State;
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

