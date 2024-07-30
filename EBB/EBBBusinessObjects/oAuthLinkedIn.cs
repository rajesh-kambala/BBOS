/*
 http://developer.linkedin.com/thread/1190?tstart=0
 This file was modified by Fatih YASAR at 27.11.2009
 */
using System;
using System.Data;
using System.Configuration;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Net;
using System.IO;
using System.Collections.Specialized;

using TSI.Utils;

namespace PRCo.EBB.BusinessObjects
{
    public class oAuthLinkedIn : oAuthBase2
    {
        public enum Method { GET, POST, PUT, DELETE };
        public const string REQUEST_TOKEN = "https://api.linkedin.com/uas/oauth/requestToken";
        public const string AUTHORIZE = "https://api.linkedin.com/uas/oauth/authorize";
        public const string ACCESS_TOKEN = "https://api.linkedin.com/uas/oauth/accessToken";

        private string _consumerKey = "";
        private string _consumerSecret = "";
        private string _token = "";
        private string _tokenSecret = "";

        private string _callbackURL = null;

        #region Properties
        public string ConsumerKey
        {
            get
            {
                if (string.IsNullOrEmpty(_consumerKey))
                {
                    _consumerKey = Utilities.GetConfigValue("LinkedInAPIConsumerKey", "NiLU3aMU7cI0UU4BOcYu4-0wnNhHN0TivcHgqIVUyy-hXbQicPm1KJWdK56IJ-nP");
                }
                return _consumerKey;
            }
            set { _consumerKey = value; }
        }

        public string ConsumerSecret
        {
            get
            {
                if (string.IsNullOrEmpty(_consumerSecret))
                {
                    _consumerSecret = Utilities.GetConfigValue("LinkedInAPIConsumerSecret", "37Ho1MXPaTLNxwdemg-VPFgVHwXA0uLcrQifU1mpTPnM01zLyOLuVMlPqpXAhe15");
                }
                return _consumerSecret;
            }
            set { _consumerSecret = value; }
        }

        public string Token { get { return _token; } set { _token = value; } }
        public string TokenSecret { get { return _tokenSecret; } set { _tokenSecret = value; } }
        public string CallbackURL { get { return _callbackURL; } set { _callbackURL = value; } }
        #endregion

        /// <summary>
        /// Get the link to Twitter's authorization page for this application.
        /// </summary>
        /// <returns>The url with a valid request token, or a null string.</returns>
        public string AuthorizationLinkGet()
        {
            string ret = null;

            string response = oAuthWebRequest(Method.GET, REQUEST_TOKEN, String.Empty);
            if (response.Length > 0)
            {
                //response contains token and token secret.  We only need the token.
                //oauth_token=36d1871d-5315-499f-a256-7231fdb6a1e0&oauth_token_secret=34a6cb8e-4279-4a0b-b840-085234678ab4&oauth_callback_confirmed=true
                NameValueCollection qs = HttpUtility.ParseQueryString(response);
                if (qs["oauth_token"] != null)
                {
                    this.Token = qs["oauth_token"];
                    this.TokenSecret = qs["oauth_token_secret"];
                    ret = AUTHORIZE + "?oauth_token=" + this.Token;
                }
            }
            return ret;
        }

        /// <summary>
        /// Exchange the request token for an access token.
        /// </summary>
        /// <param name="authToken">The oauth_token is supplied by the authorization page following the callback.</param>
        public void AccessTokenGet(string authToken)
        {
            this.Token = authToken;

            string response = oAuthWebRequest(Method.GET, ACCESS_TOKEN, string.Empty);

            if (response.Length > 0)
            {
                //Store the Token and Token Secret
                NameValueCollection qs = HttpUtility.ParseQueryString(response);
                if (qs["oauth_token"] != null)
                {
                    this.Token = qs["oauth_token"];
                }
                if (qs["oauth_token_secret"] != null)
                {
                    this.TokenSecret = qs["oauth_token_secret"];
                }
            }
        }

        /// <summary>
        /// Submit a web request using oAuth.
        /// </summary>
        /// <param name="method">GET or POST</param>
        /// <param name="url">The full url, including the querystring.</param>
        /// <param name="postData">Data to post (querystring format)</param>
        /// <returns>The web server response.</returns>
        public string oAuthWebRequest(Method method, string url, string postData)
        {
            string outUrl = "";
            string querystring = "";
            string ret = "";


            //Setup postData for signing.
            //Add the postData to the querystring.
            if (method == Method.POST || method == Method.PUT)
            {
                if (postData.Length > 0)
                {
                    //Decode the parameters and re-encode using the oAuth UrlEncode method.
                    NameValueCollection qs = HttpUtility.ParseQueryString(postData);
                    postData = "";
                    foreach (string key in qs.AllKeys)
                    {
                        if (postData.Length > 0)
                        {
                            postData += "&";
                        }
                        qs[key] = HttpUtility.UrlDecode(qs[key]);
                        qs[key] = this.UrlEncode(qs[key]);
                        postData += key + "=" + qs[key];

                    }
                    if (url.IndexOf("?") > 0)
                    {
                        url += "&";
                    }
                    else
                    {
                        url += "?";
                    }
                    url += postData;
                }
            }

            Uri uri = new Uri(url);

            string nonce = this.GenerateNonce();
            string timeStamp = this.GenerateTimeStamp();

            //Generate Signature
            string sig = this.GenerateSignature(uri,
                this.ConsumerKey,
                this.ConsumerSecret,
                this.Token,
                this.TokenSecret,
                method.ToString(),
                timeStamp,
                nonce,
                out outUrl,
                out querystring,
                this.CallbackURL);


            querystring += "&oauth_signature=" + HttpUtility.UrlEncode(sig);

            //Convert the querystring to postData
            if (method == Method.POST)
            {
                postData = querystring;
                querystring = "";
            }

            if (querystring.Length > 0)
            {
                outUrl += "?";
            }

            if (method == Method.POST || method == Method.GET)
                ret = WebRequest(method, outUrl + querystring, postData);
            //else if (method == Method.PUT)
            //ret = WebRequestWithPut(outUrl + querystring, postData);
            return ret;
        }

        /// <summary>
        /// Web Request Wrapper
        /// </summary>
        /// <param name="method">Http Method</param>
        /// <param name="url">Full url to the web resource</param>
        /// <param name="postData">Data to post in querystring format</param>
        /// <returns>The web server response.</returns>
        public string WebRequestWithPut(Method method, string url, string postData)
        {

            //oauth_consumer_key=5s5OSkySDF_mG_dLkduT3l7gokQ68hBtEpY5a9ebJVDH2r5BG8Opb6mUQhPgmQEB
            //oauth_nonce=9708457
            //oauth_signature_method=HMAC-SHA1
            //oauth_timestamp=1259135648
            //oauth_token=387026c7-27bd-4a11-b76e-fbe052ce88ad
            //oauth_verifier=31838
            //oauth_version=1.0
            //oauth_signature=4wYKoBy4ndrR4ziDNTd5mQV%2fcLY%3d

            url = "http://api.linkedin.com/v1/people/~/current-status";
            Uri uri = new Uri(url);

            string nonce = this.GenerateNonce();
            string timeStamp = this.GenerateTimeStamp();

            string outUrl, querystring;

            //Generate Signature
            string sig = this.GenerateSignatureBase(uri,
                this.ConsumerKey,
                this.ConsumerSecret,
                this.Token,
                this.TokenSecret,
                "PUT",
                timeStamp,
                nonce,
                out outUrl,
                out querystring,
                this.CallbackURL);

            querystring += "&oauth_signature=" + HttpUtility.UrlEncode(sig);
            NameValueCollection qs = HttpUtility.ParseQueryString(querystring);
            string xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
            xml += "<current-status>is setting their status using the LinkedIn API.</current-status>";

            HttpWebRequest webRequest = null;
            string responseData = "";

            webRequest = System.Net.WebRequest.Create(url) as HttpWebRequest;
            webRequest.ContentType = "text/xml";
            webRequest.Method = "PUT";
            webRequest.ServicePoint.Expect100Continue = false;

            webRequest.Headers.Add("Authorization", "OAuth realm=\"http://api.linkedin.com/\"");
            webRequest.Headers.Add("oauth_consumer_key", this.ConsumerKey);
            webRequest.Headers.Add("oauth_token", this.Token);
            webRequest.Headers.Add("oauth_signature_method", "HMAC-SHA1");
            webRequest.Headers.Add("oauth_signature", sig);
            webRequest.Headers.Add("oauth_timestamp", timeStamp);
            webRequest.Headers.Add("oauth_nonce", nonce);
            webRequest.Headers.Add("oauth_verifier", this.Verifier);
            webRequest.Headers.Add("oauth_version", "1.0");

            //webRequest.KeepAlive = true;

            StreamWriter requestWriter = new StreamWriter(webRequest.GetRequestStream());
            try
            {
                requestWriter.Write(postData);
            }
            catch
            {
                throw;
            }
            finally
            {
                requestWriter.Close();
                requestWriter = null;
            }


            HttpWebResponse response = (HttpWebResponse)webRequest.GetResponse();
            string returnString = response.StatusCode.ToString();

            webRequest = null;

            return responseData;

        }


        /// <summary>
        /// Web Request Wrapper
        /// </summary>
        /// <param name="method">Http Method</param>
        /// <param name="url">Full url to the web resource</param>
        /// <param name="postData">Data to post in querystring format</param>
        /// <returns>The web server response.</returns>
        public string WebRequest(Method method, string url, string postData)
        {
            HttpWebRequest webRequest = null;
            StreamWriter requestWriter = null;
            string responseData = "";

            webRequest = System.Net.WebRequest.Create(url) as HttpWebRequest;
            webRequest.Method = method.ToString();
            webRequest.ServicePoint.Expect100Continue = false;
            //webRequest.UserAgent  = "Identify your application please.";
            //webRequest.Timeout = 20000;

            if (method == Method.POST || method == Method.PUT)
            {
                if (method == Method.PUT)
                {
                    webRequest.ContentType = "text/xml";
                    webRequest.Method = "PUT";
                }
                else
                    webRequest.ContentType = "application/x-www-form-urlencoded";

                //POST the data.
                requestWriter = new StreamWriter(webRequest.GetRequestStream());
                try
                {
                    requestWriter.Write(postData);
                }
                catch
                {
                    throw;
                }
                finally
                {
                    requestWriter.Close();
                    requestWriter = null;
                }
            }

            responseData = WebResponseGet(webRequest);

            webRequest = null;

            return responseData;

        }

        /// <summary>
        /// Process the web response.
        /// </summary>
        /// <param name="webRequest">The request object.</param>
        /// <returns>The response data.</returns>
        public string WebResponseGet(HttpWebRequest webRequest)
        {
            StreamReader responseReader = null;
            string responseData = "";
            HttpWebResponse response = null;

            try
            {
                response = (HttpWebResponse)webRequest.GetResponse();
                responseReader = new StreamReader(response.GetResponseStream());
                responseData = responseReader.ReadToEnd();
            }
            catch
            {
                throw;
            }
            finally
            {
                webRequest.GetResponse().GetResponseStream().Close();
                responseReader.Close();
                responseReader = null;
            }

            return responseData;
        }
    }
}