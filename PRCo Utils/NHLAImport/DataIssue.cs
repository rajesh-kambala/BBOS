using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NHLAImport
{
    public class DataIssue
    {
        public string Issue { get; set; }
        public string Type { get; set;  }
        public enum IssueTypes { City, Phone, Fax, Classification, Product, ImportRegion, ExportRegion, PrimaryAddress, SecondaryAddress, PersonName };
    }
}
