using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Prorater
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private bool _reset = false;
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            try
            {
                resetControls();
            }
            catch (Exception eX)
            {
                MessageBox.Show(string.Format("There is an error\n{0}", eX.Message));
            }
        }


        private void resetControls()
        {
            _reset = true;
            previousService.Items.Clear();
            newService.Items.Clear();

            foreach(Product product in getProducts()) {
                previousService.Items.Add(product.Name + " ($" + product.Price.ToString("0.00") + ")");
                newService.Items.Add(product.Name + " ($" + product.Price.ToString("0.00") + ")");
            }

            previousService.SelectedIndex = 0;
            //comboBox1.Text = string.Empty;

            newService.SelectedIndex = 0;

            cycleCode.Items.Clear();
            for (int i = 1; i <= 12; i++)
            {
                cycleCode.Items.Add(i.ToString("00"));
            }
            cycleCode.SelectedIndex = 0;
            lblOutput.Text = string.Empty;

            _reset = false;
        }

        private const string SQL_SELECT_PRODUCTS =
            @"SELECT ItemCode, ItemCodeDesc, StandardUnitPrice, ProductLine
                FROM MAS_PRC.dbo.CI_Item WITH (NOLOCK)
               WHERE StandardUnitPrice > 0
                 AND UseInSO = 'Y'
            ORDER BY CAST(Category1 as Int)";
        private List<Product> _products = null;
        private List<Product> getProducts()
        {
            if (_products == null)
            {
                _products = new List<Product>();
                _products.Add(new Product("None", 0));
                
                using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["MAS"].ConnectionString))
                {
                    sqlConn.Open();
                    SqlCommand selectProducts = new SqlCommand(SQL_SELECT_PRODUCTS, sqlConn);

                    using (SqlDataReader reader = selectProducts.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            _products.Add(new Product(reader.GetString(0) + " - " + reader.GetString(1), reader.GetDecimal(2)));
                        }
                    }
                }
            }
            return _products;
        }

        private void btnCalculate_Click(object sender, EventArgs e)
        {
            if (_reset)
            {
                return;
            }

            decimal finalCost = calculatePrice();
            lblOutput.Text = "$" + finalCost.ToString("###,##0.000");
        }

        private void copyToClipboard()
        {
            decimal finalCost = calculatePrice();
            Clipboard.SetText(finalCost.ToString("#####0.000"));
        }

        private void btnClipboard_Click(object sender, EventArgs e)
        {
            copyToClipboard();
        }

        private void previousService_SelectedIndexChanged(object sender, EventArgs e)
        {
            btnCalculate_Click(null, null);
        }

        private void newService_SelectedIndexChanged(object sender, EventArgs e)
        {
            btnCalculate_Click(null, null);
        }

        private void cycleCode_SelectedIndexChanged(object sender, EventArgs e)
        {
            btnCalculate_Click(null, null);
        }


        private bool displayWorkingValues = false;
        private decimal calculatePrice()
        {

            decimal oldPrice = 0;
            decimal newPrice = 0;

            if (previousService.SelectedIndex >= 0)
            {
                oldPrice = ((Product)getProducts()[previousService.SelectedIndex]).Price;
            }
            newPrice = ((Product)getProducts()[newService.SelectedIndex]).Price;
            decimal perDayPrice = Math.Round((newPrice - oldPrice) / 365M, 2); ;

            int billingCycle = cycleCode.SelectedIndex + 1;
            DateTime nextCycleDate = new DateTime(DateTime.Today.Year, billingCycle, 1);
            if (nextCycleDate < DateTime.Today)
            {
                nextCycleDate = nextCycleDate.AddYears(1);
            }

            TimeSpan dateDiff = nextCycleDate.Subtract(DateTime.Today);

            decimal proratedPrice = perDayPrice * (decimal)dateDiff.TotalDays;
            proratedPrice = Math.Round(proratedPrice, 3);

            decimal finalCost = proratedPrice;

            if (displayWorkingValues)
            {
                string msg = string.Empty;
                msg += "Old Price: " + oldPrice.ToString() + Environment.NewLine;
                msg += "New Price: " + newPrice.ToString() + Environment.NewLine;
                msg += "Price per Day: " + perDayPrice.ToString() + Environment.NewLine;
                msg += "Next Cycle Date: " + nextCycleDate.ToString() + Environment.NewLine;
                msg += "Number of Days: " + dateDiff.TotalDays.ToString() + Environment.NewLine;
                msg += "Prorated Price: " + proratedPrice.ToString() + Environment.NewLine;

                MessageBox.Show(msg, "Working Values", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

            return finalCost;
            
        }

        private void btnReset_Click(object sender, EventArgs e)
        {
            resetControls();
        }


    }

    public class Product
    {
        public string Name;
        public decimal Price;

        public Product(string name, decimal price)
        {
            this.Name = name;
            this.Price = price;
        }

    }
}
