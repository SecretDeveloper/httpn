using System;
using System.IO;
using System.Net;
using System.Web;

namespace HttpNet
{
    public class HttpRequest
    {
        public string Get(string url)
        {
            var request = (HttpWebRequest)WebRequest.Create(url);
            try
            {
                using (WebResponse response = request.GetResponse())
                {
                    using (var streamReader = new StreamReader(response.GetResponseStream()))
                        return streamReader.ReadToEnd();
                }
            }
            catch (WebException e)
            {
                using (WebResponse response = e.Response)
                {
                    HttpWebResponse httpResponse = (HttpWebResponse)response;
                    Console.WriteLine("Error code: {0}", httpResponse.StatusCode);
                    using (var streamReader = new StreamReader(response.GetResponseStream()))
                        return streamReader.ReadToEnd();
                }
            }
        }
    }

    public class HttpResponse:System.Web.HttpResponseBase
    {
        public string Text { get; set; }
    }
}
