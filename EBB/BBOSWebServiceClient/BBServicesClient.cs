using System;
using System.Collections.Generic;
using System.Configuration;
using System.ServiceModel.Configuration;
using System.Linq;
using System.Net;
using System.Text;
using System.ServiceModel;
using System.IO;
using System.Xml;
using System.Xml.Serialization;

using BBOSWebServiceClient.BBServices;

namespace BBOSWebServiceClient
{
    public class BBServicesClient
    {
        protected BlueBookWebServicesSoapClient _oBBServicesClient;
        protected string _szLicenseKey;
        protected string _szLicensePassword;
        protected string _szUserEmail;
        protected string _szUserPassword;

        public string FilePrefix;

        protected void InitializeService()
        {
            _oBBServicesClient = new BlueBookWebServicesSoapClient();

            FilePrefix = _oBBServicesClient.Endpoint.Address.Uri.Host;

            _szLicenseKey = ConfigurationManager.AppSettings["LicenseKey"];
            _szLicensePassword = ConfigurationManager.AppSettings["LicenseKeyPassword"];
            _szUserEmail = ConfigurationManager.AppSettings["UserEmail"];
            _szUserPassword = ConfigurationManager.AppSettings["UserPassword"];

        }

        public int GetBusinessReport(int iBBID)
        {
            InitializeService();

            byte[] report = _oBBServicesClient.GetBusinessReport(_szLicenseKey,
                                                                _szLicensePassword,
                                                                _szUserEmail,
                                                                _szUserPassword,
                                                                iBBID);

            string fileName = $"{AppDomain.CurrentDomain.BaseDirectory}\\Business Report {iBBID}.pdf";
            File.WriteAllBytes(fileName, report);

            Console.WriteLine($"Business report PDF written to {fileName}");

            return 1;
        }


        public int GetListingDataForCompany(int iBBID)
        {
            InitializeService();

            Company oCompany = _oBBServicesClient.GetListingDataForCompany(_szLicenseKey,
                                                                           _szLicensePassword,
                                                                           _szUserEmail,
                                                                           _szUserPassword,
                                                                           iBBID);

            WriteXMLToDisk(oCompany, "GetListingDataForCompany.xml");

            return 1;
        }

        public int GetListingDataForAllCompanies()
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetListingDataForAllCompanies(_szLicenseKey,
                                                                           _szLicensePassword,
                                                                           _szUserEmail,
                                                                           _szUserPassword);

            WriteXMLToDisk(oCompany, "GetListingDataForAllCompanies.xml");

            return oCompany.Length;
        }


        public int GetListingAndPersonDataForAllCompanies()
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetListingAndPersonDataForAllCompanies(_szLicenseKey,
                                                                           _szLicensePassword,
                                                                           _szUserEmail,
                                                                           _szUserPassword);

            WriteXMLToDisk(oCompany, "GetListingAndPersonDataForAllCompanies.xml");
            return oCompany.Length;
        }


        public int GetGeneralCompanyData(string szCompanyIDList)
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetGeneralCompanyData(_szLicenseKey,
                                                                           _szLicensePassword,
                                                                           _szUserEmail,
                                                                           _szUserPassword,
                                                                           szCompanyIDList);

            WriteXMLToDisk(oCompany, "GetGeneralCompanyData.xml");

            return oCompany.Length;
        }

        public int GetRatingCompanyData(string szCompanyIDList)
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetRatingCompanyData(_szLicenseKey,
                                                                         _szLicensePassword,
                                                                         _szUserEmail,
                                                                         _szUserPassword,
                                                                         szCompanyIDList);

            WriteXMLToDisk(oCompany, "GetRatingCompanyData.xml");

            return oCompany.Length;
        }


        public int GetListingDataForWatchdogList(string szWatchdogListName)
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetListingDataForWatchdogList(_szLicenseKey,
                                                                         _szLicensePassword,
                                                                         _szUserEmail,
                                                                         _szUserPassword,
                                                                         szWatchdogListName);

            WriteXMLToDisk(oCompany, "GetListingDataForWatchdogList.xml");

            return oCompany.Length;
        }

        public int GetListingDataForCompanyList(string companyIDList)
        {
            InitializeService();

            Company[] oCompany = _oBBServicesClient.GetListingDataForCompanyList(_szLicenseKey,
                                                                         _szLicensePassword,
                                                                         _szUserEmail,
                                                                         _szUserPassword,
                                                                         companyIDList);

            WriteXMLToDisk(oCompany, "GetListingDataForCompanyList.xml");

            return oCompany.Length;
        }

        protected int WriteXMLToDisk(Object oResult, string szFileName)
        {
            StringBuilder sbXML = new StringBuilder();            

            if (oResult is Company)
            {
                XmlSerializer xs = new XmlSerializer(typeof(Company));

                StringWriter xmlTextWriter = new StringWriter(sbXML);
                xs.Serialize(xmlTextWriter, oResult);
                xmlTextWriter.Close();
            }
            
            if (oResult is Company[])
            {
                XmlSerializer xs = new XmlSerializer(typeof(Company[]));

                StringWriter xmlTextWriter = new StringWriter(sbXML);
                xs.Serialize(xmlTextWriter, oResult);
                xmlTextWriter.Close();
            }

            string szOutputDirectory = Path.GetDirectoryName(System.Reflection.Assembly.GetExecutingAssembly().GetName().CodeBase).Substring(6);
            szOutputDirectory = Path.Combine(szOutputDirectory, FilePrefix + "_" + szFileName);

            using (StreamWriter sw = new StreamWriter(szOutputDirectory,false, Encoding.Unicode))
            {
                sw.WriteLine(sbXML.ToString());
            }

            return sbXML.Length;
        }
    }
}
