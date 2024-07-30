using System;
using System.Collections.Generic;

namespace PRCo.BBOS.FaxInterface
{
    public class Driver
    {
        static void Main(string[] args)
        {

            //FaxResult faxResult = null;

            try
            {
                List<FaxResult> faxErrors = ConcordFaxProvider.GetFaxResponseReport("cthoms@bluebookservices.com",
                                                                                "cc0rd_2011",
                                                                                138224,
                                                                                new DateTime(2019, 7, 21, 5, 30, 00, DateTimeKind.Local),
                                                                                new DateTime(2019, 8, 3, 5, 30, 00, DateTimeKind.Local));

                using (System.IO.StreamWriter file = new System.IO.StreamWriter(@"C:\Temp\FaxErrors.sql"))
                {
                    foreach (FaxResult faxResult2 in faxErrors)
                    {
                        file.WriteLine(string.Format("UPDATE PRCommunicationLog SET prcoml_Failed='Y', prcoml_FailedMessage='{0}' WHERE prcoml_TranslatedFaxID = '{1}'", faxResult2.FailedMsg, faxResult2.TranslatedFaxID));
                    }
                }



                //faxResult = ConcordFaxProvider.SendFax("mbx14561504", "8105", "cwalls@travant.com", "18476820414", "Chris Walls", @"C:\Users\Chris\Desktop\TEST.pdf");
                ////faxResult = ConcordFaxProvider.SendFax("mbx14561504", "8105", "18476804777", "Chris Walls", @"C:\Users\Chris\Desktop\TEST.pdf");

                //string jobID = faxResult.FaxID;

                //if (faxResult.ResultCode == FaxResult.SUCCESS)
                //{
                //    Console.WriteLine("Fax sent: " + jobID);
                //}
                //else
                //{
                //    Console.WriteLine();
                //    Console.ForegroundColor = ConsoleColor.Red;
                //    Console.WriteLine(faxResult.ResultCode.ToString());
                //    Console.WriteLine(faxResult.ResultMessage);
                //    Console.ForegroundColor = ConsoleColor.Gray;
                //}


                //faxResult = ConcordFaxProvider.GetFaxStatus("mbx14561504", "8105", jobID);
                //if (faxResult.ResultCode == FaxResult.SUCCESS)
                //{
                //    Console.WriteLine("Fax Status");
                //    Console.WriteLine(" - " + faxResult.StatusID);
                //    Console.WriteLine(" - " + faxResult.StatusMessage);
                //}
                //else
                //{
                //    Console.WriteLine();
                //    Console.ForegroundColor = ConsoleColor.Red;
                //    Console.WriteLine(faxResult.ResultCode.ToString());
                //    Console.WriteLine(faxResult.ResultMessage);
                //    Console.ForegroundColor = ConsoleColor.Gray;
                //}

            }
            catch (Exception e)
            {
                Console.WriteLine();
                Console.WriteLine();
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("An unexpected exception occurred: " + e.Message);
                Console.WriteLine(e.StackTrace);
                Console.WriteLine("Terminating execution.");
                Console.ForegroundColor = ConsoleColor.Gray;
            }

            //sendFax("Mark", "Erickson", "merickson@bluebookservices.com", "mbx14561904", "696097");
            //sendFax("Kathi", "Orlowski", "korlowski@bluebookservices.com", "mbx14562087", "938849");
            //sendFax("Anne", "MacDonald", "amacdonald@bluebookservices.com", "mbx14561867", "418852");
            //sendFax("Bill", "Zentner", "bzentner@bluebookservices.com", "mbx14564193", "413839");
            //sendFax("Jim", "Carr", "jcarr@bluebookservices.com", "mbx14562262", "349278");
            //sendFax("Carol", "McGoldrick", "cmcgoldrick@bluebookservices.com", "mbx14562565", "173803");
            //sendFax("Dimitra", "Martin", "dmartin@bluebookservices.com", "mbx14563328", "8782");
            //sendFax("Nadine", "McNear", "nmcnear@bluebookservices.com", "mbx14564568", "212852");
            //sendFax("Greg", "Feltz", "gfeltz@bluebookservices.com", "mbx14565051", "931558");
            //sendFax("Jeff", "Lair", "JLair@bluebookservices.com", "mbx14564690", "983151");
            //sendFax("Julie", "Brown", "jbrown@bluebookservices.com", "mbx14562174", "105579");
            //sendFax("Jason", "Crowley", "jcrowley@bluebookservices.com", "mbx14564092", "819400");
            //sendFax("Ken", "Schultz", "kschultz@bluebookservices.com", "mbx14563512", "993869");
            //sendFax("Leticia", "Lima", "llima@bluebookservices.com", "mbx14565868", "430391");
            //sendFax("Lynn", "Rayos", "lrayos@bluebookservices.com", "mbx14562668", "316451");
            //sendFax("Laura", "Brown", "lbrown@bluebookservices.com", "mbx14561764", "135597");
            //sendFax("Larry", "McDaniel", "lmcdaniel@bluebookservices.com", "mbx14563640", "280074");
            //sendFax("Mary", "Niemiec", "mniemiec@bluebookservices.com", "mbx14565964", "927522");
            //sendFax("Steve", "Jacobs", "sjacobs@bluebookservices.com", "mbx14565762", "4946");
            //sendFax("Tom", "Pfaff", "tpfaff@bluebookservices.com", "mbx14562493", "876156");
            //sendFax("Vicky", "Betancourt", "vbetancourt@bluebookservices.com", "mbx14563898", "996074");
            //sendFax("Doug", "Nelson", "dnelson@bluebookservices.com", "mbx14564942", "866059");
            //sendFax("Frank", "Sanchez", "fsanchez@bluebookservices.com", "mbx14566176", "842616");
            //sendFax("Cliff", "Sieloff", "csieloff@bluebookservices.com", "mbx14564790", "291670");
            //sendFax("Judy", "Mangini", "jmangini@bluebookservices.com", "mbx14564892", "333134");
            //sendFax("Nicole", "Gilliland", "ngilliland@bluebookservices.com", "mbx14565129", "993752");
            //sendFax("Iris", "Muniz", "imuniz@bluebookservices.com", "mbx14562310", "751726");
            //sendFax("Dan", "Steeve", "dsteeve@bluebookservices.com", "mbx14563720", "780017");
            //sendFax("Trent", "Johnson", "tjohnson@bluebookservices.com", "mbx14562720", "913000");
            //sendFax("Tony", "Augello", "taugello@bluebookservices.com", "mbx14565271", "7859");
            //sendFax("Renee", "Dunham", "rdunham@bluebookservices.com", "mbx14564421", "943362");
            //sendFax("Mark", "Jorgensen", "mjorgensen@bluebookservices.com", "mbx14563134", "550570");
            //sendFax("Taryn", "Pfalzgraf", "tpfalzgraf@bluebookservices.com", "mbx14563246", "600794");
            //sendFax("Joe", "Winckowski", "jwinckowski@bluebookservices.com", "mbx14565609", "798221");
            //sendFax("Sandy", "Bach", "sbach@bluebookservices.com", "mbx14565317", "645449");
            //sendFax("Tim", "Reardon", "treardon@bluebookservices.com", "mbx14564220", "860444");
            //sendFax("Steve", "Rempert", "srempert@bluebookservices.com", "mbx14562820", "395164");
            //sendFax("John", "Hodur", "jhodur@bluebookservices.com", "mbx14562982", "684788");
            //sendFax("Eloy", "Cortes", "ecortes@bluebookservices.com", "mbx14564392", "289415");


            Console.Write("Press any key to continue . . . ");
            Console.ReadKey(true);            
        }

        static private void sendFax(string firstName, string lastName, string email, string userID, string password)
        {
            string msg = lastName + "," + firstName + "," + email + "," + userID + "," + password + ","; 

            FaxResult faxResult = null;

            try
            {
                faxResult = ConcordFaxProvider.SendFax(userID, password, "cwalls@travant.com", "18476820414", "Chris Walls", @"C:\Users\Chris\Desktop\TEST.pdf");

                if (faxResult.ResultCode == FaxResult.SUCCESS)
                {
                    msg += "Success";
                }
                else
                {
                    msg += faxResult.ResultMessage + " (" + faxResult.ResultCode.ToString() + ")";
                }

                Console.WriteLine(msg);
            }
            catch (Exception e)
            {
                msg += "EXCEPTION: " + e.Message;
                Console.WriteLine(msg);
            }

        }
    }
}
