using System;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace HttpNet.Tests
{
    [TestClass]
    public class HttpRequestTests
    {
        [TestMethod]
        public void Can_GET_URL()
        {
            var request = new HttpNet.HttpRequest();
            var response = request.Get("http://httpbin.org/get");

            //Assert.IsFalse(string.IsNullOrEmpty(response.Text));
        }
    }
}
