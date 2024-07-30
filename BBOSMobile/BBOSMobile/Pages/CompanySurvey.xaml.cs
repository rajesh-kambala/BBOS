using BBOSMobile.Forms.ViewModels;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Xamarin.Forms;
using Xamarin.Forms.Xaml;

using BBOSMobile.Core;
using BBOSMobile.ServiceModels.Requests;
using BBOSMobile.Core.Interfaces;
using BBOSMobile.Core.Models;
using System.Diagnostics;
using BBOSMobile.ServiceModels.Responses;

namespace BBOSMobile.Forms.Pages
{
    [XamlCompilation(XamlCompilationOptions.Compile)]
    public partial class CompanySurvey : BaseContentPage
    {

        public static CompanySurveyViewModel ViewModel;
        public static bool ShouldKeepContent;
        public UserCredentials userCredentials = DependencyService.Get<IUserCredentialsService>().GetUserCredentials();

        private ServiceModels.Common.Company company;

        public CompanySurvey(ServiceModels.Common.Company company)
        {

            IsBusy = true;

            CompanySurvey.ShouldKeepContent = true;


            CompanySurvey.ViewModel = new CompanySurveyViewModel();
            CompanySurvey.ViewModel.SecurityPrivileges = userCredentials.SecurityPrivileges;


            InitializeComponent();
            this.company = company;


            if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
                ViewModel.IsLumber = true;
            else
                ViewModel.IsLumber = false;
            BindingContext = CompanySurvey.ViewModel;

            SetPageView();


            Title = "Trade Survey";
            label_company_name.Text = company.Name;
            label_company_location.Text = company.Location;
            label_company_bbid.Text = "BBID #" + company.BBID.ToString();



            IsBusy = false;

        }

        protected override void OnDisappearing()
        {

            if (ShouldClearContent(CompanySurvey.ShouldKeepContent))
            {
                //viewModel = null;
            }



            base.OnDisappearing();
        }


        protected override void OnAppearing()
        {


            //BindingContext = CompanySurvey.ViewModel;


            Debug.WriteLine("COMPANY SURVEY -- ON APPEARING");


            IsBusy = true;
            if (ViewModel != null && !ViewModel.IsLumber)
            {

            }

            base.OnAppearing();
            //SetSubmitButtonState();

            IsBusy = false;
        }


        private async void OnBtnSubmitSurveyClicked(object sender, EventArgs args)
        {
            if (!IsBusy)
            {
                IsBusy = true;

                SaveTradeReportRequest request = new SaveTradeReportRequest();
                request.Comments = SurveyComments.Text;
                request.CompanyLastDealt = ViewModel.SelectedLastDealt.Code;
                request.HighCreditRating = ViewModel.SelectedHighCredit.Code;
                //request.IndustryType = company.Industry;
                request.OutOfBusiness = ViewModel.SelectedOutOfBusiness.Value;
                request.PayPerformanceRating = ViewModel.SelectedPayPerformance.Code;
                //request.ResponderCompanyID = userCredentials.
                request.SubjectCompanyID = this.company.BBID;
                request.TradePracticeRating = ViewModel.SelectedTradePractice.Code;
                request.UserId = userCredentials.UserId;




                var serviceClient = new CompanyWebserviceClient();

                SaveTradeReportResponse response = await serviceClient.SaveTradeReport(request);



                Debug.WriteLine("trade survey response status:" + response.ResponseStatus);
                Debug.WriteLine("trade survey response error_message:" + response.ErrorMessage);

                if (response.ResponseStatus != ServiceModels.Common.Enumerations.ResponseStatus.Success)
                {

                    DisplayErrorLoadingAlert();
                }
                else {
                    await Navigation.PopAsync();
                }


                //SaveViewModel();  ///add this back later!!


                IsBusy = false;

            }

        }

        private void OnBtnCancelSurveyClicked(object sender, EventArgs args)
        {
            if (!IsBusy)
            {

                Navigation.PopAsync();
                //probably pop self
                //IsBusy = true;

                //Navigation.PushAsync(new CompanySearchResults());
                //IsBusy = false;
            }

        }

        private void SaveViewModel()
        {
            if (CompanySurvey.ViewModel == null)
                CompanySurvey.ViewModel = new CompanySurveyViewModel();



        }


        private void OnTradePracticesClicked(object sender, EventArgs e)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                //SaveViewModel();
                CompanySurvey.ViewModel.SelectedDropdown = CompanySurveyViewModel.Selection.TradePractice;

                Navigation.PushAsync(new CompanySurveyList(ViewModel));

                IsBusy = false;
            }


        }

        private void OnBtnPayPerformanceClicked(object sender, EventArgs e)
        {

            if (!IsBusy)
            {
                IsBusy = true;
                //SaveViewModel();
                CompanySurvey.ViewModel.SelectedDropdown = CompanySurveyViewModel.Selection.PayPerformance;

                Navigation.PushAsync(new CompanySurveyList(ViewModel));

                IsBusy = false;
            }

        }

        private void OnBtnHighCreditClicked(object sender, EventArgs e)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                //SaveViewModel();
                CompanySurvey.ViewModel.SelectedDropdown = CompanySurveyViewModel.Selection.HightCredit;

                Navigation.PushAsync(new CompanySurveyList(ViewModel));

                IsBusy = false;
            }

        }

        private void OnBtnLastDealtClicked(object sender, EventArgs e)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                //SaveViewModel();
                CompanySurvey.ViewModel.SelectedDropdown = CompanySurveyViewModel.Selection.LastDealt;

                Navigation.PushAsync(new CompanySurveyList(ViewModel));

                IsBusy = false;
            }
        }

        private void OnBtnOutOfBusinessClicked(object sender, EventArgs e)
        {
            if (!IsBusy)
            {
                IsBusy = true;
                //SaveViewModel();
                CompanySurvey.ViewModel.SelectedDropdown = CompanySurveyViewModel.Selection.OutOfBusiness;

                Navigation.PushAsync(new CompanySurveyList(ViewModel));

                IsBusy = false;
            }

        }

        public void SetPageView()
        {
            //Check to see if this is a lumber user.  Otherwise, assume produce
            //btnIndustry.IsVisible = true;

            /*
            if (userCredentials.UserType == BBOSMobile.ServiceModels.Common.Enumerations.UserType.Lumber)
            {

                /*
				slCommodity.IsVisible = false;
				btnBBScore.IsVisible = false;
				btnIntegrity.IsVisible = false;
                
                btnIndustry.IsVisible = false;
                
				btnTerminalMarket.IsVisible = false;
				btnCreditWorthy.IsVisible = false;
				btnPay.IsVisible = false;
                
                */


        }

        private void SetSubmitButtonState()
        {

            if ((ViewModel.SelectedTradePractice.TradePracticeID == -1) ||
            (ViewModel.SelectedPayPerformance.PayPerformanceID == -1) ||
            (ViewModel.SelectedHighCredit.HighCreditID == -1) ||
            (ViewModel.SelectedLastDealt.LastDealtID == -1) ||
            (ViewModel.SelectedOutOfBusiness.OutOfBusinessID == -1))
            {
                btnSubmitSurvey.IsEnabled = false;
            }
            else
            {
                btnSubmitSurvey.IsEnabled = true;
            }




        }

    }


}