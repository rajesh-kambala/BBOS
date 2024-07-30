using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace InfoUSAResolveUnknownCity
{
    class Program
    {
        static void Main(string[] args)
        {
            UnknownCityResolver oUnknownCityResolver = new UnknownCityResolver();
            oUnknownCityResolver.Resolve(args);
        }
    }
}
