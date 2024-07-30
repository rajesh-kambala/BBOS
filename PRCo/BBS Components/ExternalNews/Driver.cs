
namespace PRCo.BBOS.ExternalNews
{
    public class Driver
    {
        static void Main(string[] args)
        {
            DowJonesNewsProvider oDowJonesNewsProvider = new DowJonesNewsProvider();
            try
            {
                //oDowJonesNewsProvider.RefreshCompany(104559, true);
                //oDowJonesNewsProvider.RefreshAllCompanies();
                oDowJonesNewsProvider.FindCode(164486);
            }
            finally
            {
                oDowJonesNewsProvider.WriteLogToFile("DowJonesLog.txt");
            }

            //ExternalNewsMgr externalNewsMgr = new ExternalNewsMgr();
            //externalNewsMgr.RefreshAllCompanies();
        }
    }
}
