using PRCo.EBB.BusinessObjects;
using Stripe;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TSI.Utils;

namespace PRCo.BBOS.UI.Web
{
    public partial class Stripe_POC : PageBase
    {
        const string STRIPE_BBS_QA_SECRET_KEY = "sk_test_51Mf7lAGKB453XnfLhBjxdA9uVfrK2hMfaB6wnn2F8TqjqcuGGgwnUhVv8oPdJd64S6NFwGkpcyLnQFWC0xh3cGub00LhRb9I3n";

        override protected void Page_Load(object sender, EventArgs e)
        {
            if (!Request.IsLocal)
                throw new Exception("Permission error.");

            base.Page_Load(sender, e);
            SetPageTitle("Stripe Proof of Concept");

            if (IsPostBack)
            {
                // Handle Stripe payments
                NameValueCollection nvc = Request.Form;
                string hfStripeToken = nvc["hfStripeToken"];
                if (!string.IsNullOrEmpty(hfStripeToken))
                {
                    btnPay_Click(hfStripeToken);
                }
            }
        }

        /// <summary>
        /// All users can view this page.
        /// </summary>
        /// <returns></returns>
        override protected bool IsAuthorizedForPage()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege;
        }

        /// <summary>
        /// All users can view this data.
        /// </summary>
        /// <returns></returns>
        protected override bool IsAuthorizedForData()
        {
            return _oUser.HasPrivilege(SecurityMgr.Privilege.SystemAdmin).HasPrivilege;
        }

        private StripeClient GetSelectedStripeClient()
        {
            if (cbUseBBSStripe.Checked)
                return new StripeClient(STRIPE_BBS_QA_SECRET_KEY);
            else
                return new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
        }

        private void btnPay_Click(string stripeToken)
        {
            const string uniqueID = "12345678";
            const decimal amountToCharge = 1000.00M;

            lblResult1.Text = "";
            lblError1.Text = "";

            var myCharge = new ChargeCreateOptions
            {
                // convert the amount of $15.95 to pennies i.e. 1595
                Amount = (int)(amountToCharge * 100),
                Currency = "USD",
                Description = uniqueID,
                Source = stripeToken
            };

            var stripeClient = new StripeClient(Utilities.GetConfigValue("Stripe_Secret_Key"));
            var chargeService = new ChargeService(stripeClient);
            Charge stripeCharge;

            try
            {
                stripeCharge = chargeService.Create(myCharge);
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                lblError1.Text = stripeError.Message;
                return;
            }

            // Successfully Authorised, do your post-succesful payment processing here...
            lblResult1.Text = $"{DateTime.Now}</br>{stripeCharge.Outcome.SellerMessage}<br/>View <a href='{stripeCharge.ReceiptUrl}' style='color:blue'>Receipt</a><br/>Card: {stripeCharge.PaymentMethodDetails.Card.Network} x{stripeCharge.PaymentMethodDetails.Card.Last4} Exp: {stripeCharge.PaymentMethodDetails.Card.ExpMonth}/{stripeCharge.PaymentMethodDetails.Card.ExpYear}";
        }

        protected void btnCreateCustomer_Click(object sender, EventArgs e)
        {
            lblResult1.Text = "";
            lblResult2Customer.Text = "";
            lblResult2Invoice.Text = "";
            lblError1.Text = "";
            lblError2.Text = "";

            lblCustomerID.Text = "";
            lblInvoiceID.Text = "";
            

            Dictionary<string, string> metaData = new Dictionary<string, string>();
            metaData.Add("BBID", "103227");

            //var address = new AddressOptions();
            //address.Line1 = "PO Box 223529";
            //address.Line2 = "";
            //address.City = "Christiansted";
            //address.State = "VI";
            //address.PostalCode = "00822";

            var address = new AddressOptions();
            address.Line1 = "PO Box 127";
            address.Line2 = "";
            address.City = "Minto";
            address.State = "ND";
            address.PostalCode = "58261";

            var options = new CustomerCreateOptions
            {
                Description = "J. D. Miller Inc.", 
                Email = "test@travant.com",
                Metadata = metaData,
                Name = "J. D. Miller Inc.",
                Phone = "555-666-7777",
                Address = address
            };

            var stripeClient = GetSelectedStripeClient();

            Customer stripeCustomer;
            var customerService = new CustomerService(stripeClient);

            try
            {
                stripeCustomer = customerService.Create(options);
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                lblError2.Text = stripeError.Message;
                return;
            }

            lblCustomerID.Text = stripeCustomer.Id;
            lblResult2Customer.Text = $"{stripeCustomer.Created}</br>{stripeCustomer.Description}<br>{stripeCustomer.Name}<br>Id={stripeCustomer.Id}<br>BBID = {stripeCustomer.Metadata["BBID"]}<br>StatusCode = {stripeCustomer.StripeResponse.StatusCode}";
            btnCreateInvoice.Enabled = true;
        }

        protected void btnCreateInvoice_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(lblCustomerID.Text))
            {
                AddUserMessage("Must create a customer first");
                return;
            }

            lblResult1.Text = "";
            lblError1.Text = "";
            lblError2.Text = "";

            lblInvoiceID.Text = "";

            Dictionary<string, string> metaData = new Dictionary<string, string>();
            metaData.Add("BBID", "103227");
            metaData.Add("BB INVOICE", "M110347");

            List<InvoiceCustomFieldOptions> customFields = new List<InvoiceCustomFieldOptions>();
            customFields.Add(new InvoiceCustomFieldOptions { Name = "BBID", Value = "103227" });
            customFields.Add(new InvoiceCustomFieldOptions { Name = "BB Invoice", Value = "M110347" });

            var options = new InvoiceCreateOptions
            {
                Customer = lblCustomerID.Text,
                Description = "M110347",
                Metadata = metaData,
                Currency = "USD",
                CustomFields = customFields
            };

            var stripeClient = GetSelectedStripeClient();

            //Create Invoice
            Invoice stripeInvoice;
            var invoiceService = new InvoiceService(stripeClient);

            try
            {
                stripeInvoice = invoiceService.Create(options);
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                lblError2.Text = stripeError.Message;
                return;
            }

            lblInvoiceID.Text = stripeInvoice.Id;
            lblResult2Invoice.Text = $"Invoice<br>{stripeInvoice.Created}</br>ID= {stripeInvoice.Id}<br>Description={stripeInvoice.Description}<br>Status= {stripeInvoice.Status}";

            //Set tax
            //if(ddlTaxType.SelectedValue == "Overall")
                //InvoiceAddTax(stripeInvoice);

            //Add items to invoice
            InvoiceItem stripeInvoiceItem;
            var invoiceItemService = new InvoiceItemService(stripeClient);

            var itemOptions = new InvoiceItemCreateOptions
            {
                Customer = lblCustomerID.Text,
                Invoice = lblInvoiceID.Text,
                Metadata = metaData
            };
            try
            {
                //invoice M110347
                itemOptions.Quantity = 1;
                itemOptions.UnitAmount = 75525;
                itemOptions.Description = "Blue Book Service: 100 - 4/1/23-3/31/24";

                stripeInvoiceItem = invoiceItemService.Create(itemOptions);
                //if (ddlTaxType.SelectedValue == "LineItems")
                    //LineItemAddTax(stripeInvoiceItem);

                itemOptions.Quantity = 1;
                itemOptions.UnitAmount = 18900;
                itemOptions.Description = "Descriptive Listing Lines (Qty 9) - 4/1/23-3/31/24";
                stripeInvoiceItem = invoiceItemService.Create(itemOptions);
                //if (ddlTaxType.SelectedValue == "LineItems")
                //LineItemAddTax(stripeInvoiceItem);

                itemOptions.Quantity = 1;
                itemOptions.UnitAmount = 4720;
                itemOptions.Description = "Tax";
                stripeInvoiceItem = invoiceItemService.Create(itemOptions);
                //if (ddlTaxType.SelectedValue == "LineItems")
                //LineItemAddTax(stripeInvoiceItem);
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                lblError2.Text = stripeError.Message;
                return;
            }

            lblResult2Invoice.Text += $"<br><br>Invoice Items added";

            //Finalize invoice
            Invoice stripeInvoiceFinalized;
            stripeInvoiceFinalized = invoiceService.FinalizeInvoice(lblInvoiceID.Text);

            lblResult2Invoice.Text += $"<br><br>Finalized Invoice<br>ID= {stripeInvoiceFinalized.Id}<br><a href='{stripeInvoiceFinalized.HostedInvoiceUrl}' style='color:blue' target='_blank'>Hosted Invoice</a><br><a href='{stripeInvoiceFinalized.InvoicePdf}' style='color:blue' target='_blank'>Invoice PDF</a><br>Payment Intent ID: {stripeInvoiceFinalized.PaymentIntentId}<br>Status = {stripeInvoiceFinalized.Status}";
        }

        private void InvoiceAddTax(Invoice invoice)
        {
            var stripeClient = GetSelectedStripeClient();

            List<string> taxRates = new List<string>();
            //taxRates.Add("txr_1N2zhAErpkaaz3RxS4zgOB2u"); //8% tax 
            var taxOptions = new InvoiceUpdateOptions
            {
                DefaultTaxRates = taxRates
                
            };
            var taxService = new InvoiceService(stripeClient);
            taxService.Update(invoice.Id, taxOptions);
        }

        private void LineItemAddTax(InvoiceItem stripeInvoiceItem)
        {
            var stripeClient = GetSelectedStripeClient();

            List<string> taxRates = new List<string>();
            taxRates.Add("txr_1N2zhAErpkaaz3RxS4zgOB2u"); //8% tax 
            var taxOptions = new InvoiceItemUpdateOptions
            {
                TaxRates = taxRates
            };
            var taxService = new InvoiceItemService(stripeClient);
            taxService.Update(stripeInvoiceItem.Id, taxOptions);
        }


        protected void btnCreateTaxRate_Click(object sender, EventArgs e)
        {
            lblTaxRate.Text = "";

            var options = new TaxRateCreateOptions
            {
                DisplayName = "8% Flat Tax",
                Inclusive = false,
                Percentage = 8.0m,
                Country = "US",
                Description = "US 8% Flat Tax"
            };

            var stripeClient = GetSelectedStripeClient();

            TaxRate stripeTaxRate;
            var taxRateService = new TaxRateService(stripeClient);

            try
            {
                stripeTaxRate = taxRateService.Create(options);
            }
            catch (StripeException ex)
            {
                StripeError stripeError = ex.StripeError;
                // Handle error
                lblTaxRate.Text = stripeError.Message;
                return;
            }

            lblTaxRate.Text = $"ID: {stripeTaxRate.Id}<br>{stripeTaxRate.Created}</br>{stripeTaxRate.Description}<br>Percentage: {stripeTaxRate.Percentage}<br>StatusCode = {stripeTaxRate.StripeResponse.StatusCode}";
        }
    }
}