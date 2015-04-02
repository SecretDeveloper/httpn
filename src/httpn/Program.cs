using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using HttpNet;

namespace httpn
{
    class Program
    {
        static void Main(string[] args)
        {
            HttpNet.HttpRequest req = new HttpRequest();

            Console.WriteLine(req.Get(args[0]));
        }
    }
}
