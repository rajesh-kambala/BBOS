using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CompanyMatching
{
    public static class ConsoleWriter
    {
        public static int leftCursPosTotalCompSearched;
        public static int topCursPosTotalCompSearched;
        public static int lastLeftCursPos, lastTopCursPos;
        public static int leftCursPosExecutionStatus, topCursPosExecutionStatus;
        public static int leftCursPosMainOutput, topCursPosMainOutput;
        public static List<string> lszOutputBuffer = new List<string>();

        public static void InitializeConsole()
        {
            Console.Clear();
            Console.SetWindowSize(100, 40);
            Console.BufferWidth = 300;
            Console.BufferHeight = 400;
            Console.Title = "Company Matching Utility";
            WriteLine("Company Matching Utility 1.0");
            WriteLine("Copyright (c) 2010 Produce Reporter Co.");
            WriteLine("All Rights Reserved.");
            WriteLine("OS Version: " + System.Environment.OSVersion.ToString());
            WriteLine("CLR Version: " + System.Environment.Version.ToString());
            WriteLine(string.Empty);
            WriteLine(string.Empty);

            leftCursPosMainOutput = Console.CursorLeft;
            topCursPosMainOutput = Console.CursorTop;

            Console.Write("Execution Status: ");
            leftCursPosExecutionStatus = Console.CursorLeft;
            topCursPosExecutionStatus = Console.CursorTop;

            WriteExecutionStatus("Initializing Resources...");

            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine();

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;

            Console.CursorVisible = false;
        }

        public static void FinalizeConsole(DateTime startTime, DateTime endTime)
        {
            Console.SetCursorPosition(leftCursPosExecutionStatus, topCursPosExecutionStatus);
            Console.Write("Execution Finished. -- Execution Time: " + endTime.Subtract(startTime).ToString());
            Console.CursorVisible = true;
            Console.ReadLine();
        }

        public static void WriteException(Exception e)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.SetCursorPosition(leftCursPosMainOutput, topCursPosMainOutput);
            Console.WriteLine("-------------------------- Execution Terminated ---------------------------");
            Console.WriteLine();           
            Console.WriteLine("An unexpected exception occurred: " + e.Message);
            Console.WriteLine(e.StackTrace);        
            Console.ForegroundColor = ConsoleColor.Gray;
            Console.CursorVisible = true;
            Console.ReadLine();
        }

        public static void WriteExecutionStatus(string message)
        {
            Console.SetCursorPosition(leftCursPosExecutionStatus, topCursPosExecutionStatus);
            Console.WriteLine(message);
        }

        public static void WriteCurrentCompanySearched(int counter)
        {
            Console.SetCursorPosition(leftCursPosTotalCompSearched, topCursPosTotalCompSearched);

            leftCursPosTotalCompSearched = Console.CursorLeft;
            topCursPosTotalCompSearched = Console.CursorTop;

            Console.WriteLine(counter);
            Console.SetCursorPosition(leftCursPosTotalCompSearched, topCursPosTotalCompSearched);
        }

        public static void WriteCompanyComparedText()
        {
            Console.WriteLine();
            Console.WriteLine("Total Analysis");
            Console.WriteLine("---------------------------------------------------------");
            Console.Write("Total Companies Compared: ");

            leftCursPosTotalCompSearched = Console.CursorLeft;
            topCursPosTotalCompSearched = Console.CursorTop;

            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine();

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

        public static void WriteTotalAnalysis(int totalMatched, int totalUnmatched)
        {
            Console.SetCursorPosition(leftCursPosTotalCompSearched, topCursPosTotalCompSearched);
            Console.WriteLine();
            Console.WriteLine("Total Companies Matched: " + totalMatched);
            Console.WriteLine("Total Companies Unmatched: " + totalUnmatched);
            //Console.WriteLine();
            //Console.WriteLine();
            //Console.WriteLine();
            //Console.WriteLine();

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

        public static void WriteSectionData(string message, int sectionCompaniesSearched, int sectionCompaniesMatched, int sectionCompaniesUmatched)
        {
            Console.SetCursorPosition(lastLeftCursPos, lastTopCursPos);
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine(message);
            Console.WriteLine("---------------------------------------------------------");
            Console.WriteLine("Companies Compared: " + sectionCompaniesSearched);
            Console.WriteLine("Companies Matched: " + sectionCompaniesMatched);
            Console.WriteLine("Companies Unmatched: " + sectionCompaniesUmatched);

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

        private static void WriteLine(string szLine)
        {
            Console.WriteLine(szLine);
            lszOutputBuffer.Add(szLine);
        }
    }
}
