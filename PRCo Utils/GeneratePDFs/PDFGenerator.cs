using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Threading.Tasks;

using SelectPdf;

namespace GeneratePDFs
{
    public class PDFGenerator
    {

        private const string SQL_SELECT_POSTS =
            @"SELECT id, post_date, post_title, post_content, ac.meta_value [associated-companies]
                FROM wp_4_posts
                        INNER JOIN wp_4_postmeta a ON wp_4_posts.id = a.post_id
			            LEFT OUTER JOIN wp_4_postmeta ac ON wp_4_posts.id = ac.post_id
                WHERE a.meta_key = 'Author'
                    AND a.meta_value LIKE '%Greg Johnson%'
		            AND ac.meta_key = 'associated-companies'
            ORDER BY id";

        public void Generate(string[] args)
        {
            DateTime dtStart = DateTime.Now;

            Console.Clear();
            Console.Title = "PDF Generator Utility";
            WriteLine("PDF Generator Utility 1.0");
            WriteLine("Copyright (c) 2019 Blue Book Services, Inc.");
            WriteLine("All Rights Reserved.");
            WriteLine("  OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine(" CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(DateTime.Now.ToString("M/dd/yyyy hh:mm tt"));
            WriteLine(string.Empty);

            List<WPPost> wpPosts = new List<WPPost>();
            int count = 0;
            using (SqlConnection sqlConn = new SqlConnection(ConfigurationManager.ConnectionStrings["SQLServer"].ConnectionString))
            {
                count = 0;

                sqlConn.Open();
                SqlCommand sqlCommand = new SqlCommand(SQL_SELECT_POSTS, sqlConn);
                using (SqlDataReader reader = sqlCommand.ExecuteReader(CommandBehavior.CloseConnection))
                {
                    while (reader.Read())
                    {
                        count++;
                        if (count > 999)
                            break;

                        WPPost wpPost = new WPPost();
                        wpPost.PostID = reader.GetInt64(0);
                        wpPost.PostDate = reader.GetDateTime(1);
                        wpPost.Title = reader.GetString(2);
                        wpPost.Content = reader.GetString(3);
                        wpPost.AssociatedCompanies = reader.GetString(4);
                        wpPosts.Add(wpPost);
                    }
                }
            }

            string outputFolder = ConfigurationManager.AppSettings["OutputFolder"];
            string filePath = null;
            _fileList.Add($"Post ID,Post Date,Post Title,PDF File Name,Associated Companies");

            count = 0;
            foreach (WPPost wpPost in wpPosts)
            {
                count++;
                WriteLine($" - Processing {count:###,##0} of {wpPosts.Count:###,##0}: {wpPost.Title}");

                string work = wpPost.Title.Replace('/', '-').Replace(':', ' ');
                work = work.TrimEnd('?');

                string fileName = $"{work}.pdf";

                _fileList.Add($"{wpPost.PostID:0},{wpPost.PostDate:MM/dd/yyyy},\"{wpPost.Title}\",\"{fileName}\",\"{wpPost.AssociatedCompanies}\"");
                filePath = Path.Combine(outputFolder, fileName);

                string content = $"<html><head>{HEADER}</head><body><div style=\"margin:100px 100px 100px 100px\"><h2>{wpPost.Title}</h2>{wpPost.Content}</body></div></html>";

                //SavePDF(content, filePath);
            }

            WriteLine(string.Empty);
            WriteLine("Total Record Count: " + wpPosts.Count.ToString("###,##0"));
            WriteLine("    Execution Time: " + DateTime.Now.Subtract(dtStart).ToString());

            filePath = Path.Combine(outputFolder, $"1. Article Inventory.csv");
            using (StreamWriter sw = new StreamWriter(filePath))
            {
                foreach (string line in _fileList)
                    sw.WriteLine(line);
            }

            using (StreamWriter sw = new StreamWriter(_szOutputFile))
            {
                foreach (string line in _lszOutputBuffer)
                    sw.WriteLine(line);
            }

        }

        protected void SavePDF(string html, string fileName)
        {
            // instantiate a html to pdf converter object 
            HtmlToPdf converter = new HtmlToPdf();

            // set converter options 
            converter.Options.PdfPageSize = PdfPageSize.Letter;
            converter.Options.PdfPageOrientation = PdfPageOrientation.Portrait;
            converter.Options.KeepImagesTogether = true;

            // create a new pdf document converting an url 
            PdfDocument doc = converter.ConvertHtmlString(html, "https://www.producebluebook.com/");

            // save pdf document 
            doc.Save(fileName);

            // close pdf document 
            doc.Close();
        }



        protected string _szOutputFile;
        protected List<string> _lszOutputBuffer = new List<string>();
        protected List<string> _fileList = new List<string>();

        private void WriteLine(string msg)
        {
            if (_szOutputFile == null)
            {
                _szOutputFile = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
                _szOutputFile = Path.Combine(_szOutputFile, "PDF Generator.txt");
            }

            Console.WriteLine(msg);
            _lszOutputBuffer.Add(msg);
        }

        private const string HEADER =
            "<meta charset=\"UTF-8\"><link href=\"https://www.producebluebook.com/wp-content/themes/blue-book/style.css?ver=4.9.4\" rel=\"stylesheet\" type=\"text/css\" media=\"all\">";
    }
}
