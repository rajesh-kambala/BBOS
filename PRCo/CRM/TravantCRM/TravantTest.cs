using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BBSI.CRM
{
    public class TravantTest: CRMBase
    {
        public override void BuildContents()
        {
            try
            {
                SetRequestName("TravantTest");
                TravantLogMessage($"Begin BuildContents");

                int x = 10;
                int y = 0;
                int z = x / y;

                TravantLogMessage($"End BuildContents");
            }
            catch (Exception eX)
            {
                AddContent(HandleException(eX));
            }
        }

    }
}
