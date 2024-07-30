using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BBOSMobile.ServiceModels.Common
{
    public static class Constants
    {
        public static class ErrorMessages
        {
            public const string USER_NOT_AUTHORIZED = "User is not authorized.";
            public const string USER_DOES_NOT_EXIST = "User does not exist.";
            public const string GENERIC_FAILURE = "An internal service error has occured.";
            public const string INCORRECT_LOGIN_CREDENTIALS = "Incorrect Email or Password";
            public const string EMAIL_DOES_NOT_EXIST = "Email doesn't exist.";
        }
    }
}
