using System;

namespace PRCo.BBOS.FaxInterface
{
    public class FaxResult
    {
        public static int SUCCESS = 0;

        public string FaxNumber;

        public int ResultCode;
        public string ResultMessage;
        public string AdditionalInfo;
        public Exception FaxException;
        public string FaxID;
        

        public int StatusID;
        public string StatusMessage;
        public string ErrorMessage;

        public string Failed;
        public string FailedMsg;
        public string TranslatedFaxID;

        public void TranslateFaxID()
        {
            //string tmp = FaxID.Replace("br001h", string.Empty).Replace("r17j", "-");
            //TranslatedFaxID = tmp.Substring(0, tmp.Length - 1);

            string tmp = FaxID.Substring(FaxID.IndexOf('h') + 1).Replace("r17j", "-");
            TranslatedFaxID = tmp.Substring(0, tmp.Length - 1);

        }

    }
}
