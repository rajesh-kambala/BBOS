/***********************************************************************
***********************************************************************
 Copyright Blue Book Services, Inc 2010

 The use, disclosure, reproduction, modification, transfer, or  
 transmittal of  this work for any purpose in any form or by any 
 means without the written  permission of Blue Book Services, Inc is 
 strictly prohibited.

 Confidential, Unpublished Property of Produce Reporter Co
 Use and distribution limited solely to authorized personnel.

 All Rights Reserved.

 Notice:  This file was created by Travant Solutions, Inc.  Contact
 by e-mail at info@travant.com

 ClassName: DowJonesResult
 Description:	

 Notes:	

***********************************************************************
***********************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;

namespace PRCo.BBOS.ExternalNews
{
    public class Utils
    {
        /// <summary>
        /// Helper function that ensure the specified string is 
        /// formatted for XML.
        /// </summary>
        /// <param name="szValue"></param>
        /// <returns></returns>
        public static string GetXmlString(string szValue)
        {
            if (szValue == null)
            {
                return string.Empty;
            }
            return szValue.Trim().ToUpper().Replace("&", "&amp;");
        }

        /// <summary>
        /// Helper method that returns the value for the specified
        /// XPath
        /// </summary>
        /// <param name="xd"></param>
        /// <param name="szXPath"></param>
        /// <returns></returns>
        public static string GetNodeValue(XmlDocument xd, string szXPath)
        {

            //WriteFile(@"C:\Debug.txt", szXPath);
            XmlNodeList xmlNodeList = xd.SelectNodes(szXPath);
            if (xmlNodeList.Count == 0)
            {
                return null;
            }
            return xmlNodeList[0].InnerText;
        }

        /// <summary>
        /// Helper method that returns the value for the specified
        /// parent/child nodes.  If more than one node is found it
        /// is concatenated to our value.
        /// </summary>
        /// <param name="oParentNode"></param>
        /// <param name="szChildNodeName"></param>
        /// <returns></returns>
        public static string GetNodeValue(XmlNode oParentNode, string szChildNodeName)
        {
            string szValue = string.Empty;

            foreach (XmlNode oNode in oParentNode.ChildNodes)
            {
                if (oNode.Name == szChildNodeName)
                {
                    if (szValue.Length > 0)
                    {
                        szValue += ", ";
                    }
                    szValue += oNode.InnerText;
                }
            }

            if (szValue.Length == 0)
            {
                return null;
            }
            else
            {
                return szValue;
            }
        }

        /// <summary>
        /// Helper method that returns the specified child of the parent node.
        /// </summary>
        /// <param name="oParentNode"></param>
        /// <param name="szChildNodeName"></param>
        /// <returns></returns>
        public static XmlNode GetChildNode(XmlNode oParentNode, string szChildNodeName)
        {

            foreach (XmlNode oNode in oParentNode.ChildNodes)
            {
                if (oNode.Name == szChildNodeName)
                {
                    return oNode;
                }
            }

            return null;
        }

        /// <summary>
        /// Helper method that removes the company entity type from the
        /// end of the name.
        /// </summary>
        /// <param name="szName"></param>
        /// <returns></returns>
        public static string FuzzifyCompanyName(string szName)
        {
            if (szName.LastIndexOf(',') > 0)
            {
                return szName.Substring(0, szName.LastIndexOf(','));
            }


            if (szName.ToLower().EndsWith(" co"))
            {
                return szName.Substring(0, szName.Length - 3);
            }

            if ((szName.ToLower().EndsWith(" co.")) ||
                (szName.ToLower().EndsWith(" inc")) ||
                (szName.ToLower().EndsWith(" llc")) ||
                (szName.ToLower().EndsWith(" ltd")))
            {
                return szName.Substring(0, szName.Length - 4);
            }

            if ((szName.ToLower().EndsWith(" inc.")) ||
                (szName.ToLower().EndsWith(" llc.")) ||
                (szName.ToLower().EndsWith(" ltd.")))
            {
                return szName.Substring(0, szName.Length - 5);
            }

            if (szName.ToLower().EndsWith(" corp"))
            {
                return szName.Substring(0, szName.Length - 5);
            }

            if (szName.ToLower().EndsWith(" corp."))
            {
                return szName.Substring(0, szName.Length - 6);
            }

            if (szName.ToLower().EndsWith(" Corporation"))
            {
                return szName.Substring(0, szName.Length - 12);
            }

            if (szName.ToLower().EndsWith(" co inc"))
            {
                return szName.Substring(0, szName.Length - 7);
            }

            if (szName.ToLower().EndsWith(" company inc"))
            {
                return szName.Substring(0, szName.Length - 12);
            }

            if (szName.ToLower().EndsWith(" company, inc"))
            {
                return szName.Substring(0, szName.Length - 13);
            }

            return szName;
        }

        /// <summary>
        /// Helper method that removes punctuation, white space, and
        /// the company entity from the end of the name.
        /// </summary>
        /// <param name="szName"></param>
        /// <returns></returns>
        public static string LowerAlphaFuzzifyCompanyName(string szName)
        {
            string szWorkArea = FuzzifyCompanyName(szName);

            // Remove puncuation
            szWorkArea = Regex.Replace(szWorkArea, @"(\p{P}) ", string.Empty);

            // Remove white space
            szWorkArea = szWorkArea.Replace(" ", string.Empty);

            return szWorkArea.ToLower();
        }

        private static Regex r = null;
        public static string PrepareForFileName(string szName)
        {
            if (r == null)
            {
                string regexSearch = string.Format("{0}{1}",
                                     new string(Path.GetInvalidFileNameChars()),
                                     new string(Path.GetInvalidPathChars()));
                r = new Regex(string.Format("[{0}]", Regex.Escape(regexSearch)));
            }

            return r.Replace(szName, "");

        }

        public static string GetFileName(string szCompanyName) {

            return DateTime.Now.ToString("yyyyMMdd_hhmmss_" + PrepareForFileName(szCompanyName));

        }
    }
}
