using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NHLAImport
{
    public static class ConsoleWriter
    {
        public static int leftCursPosTotalCompImported;
        public static int topCursPosTotalCompImported;
        public static int lastLeftCursPos, lastTopCursPos;
        public static int leftCursPosExecutionStatus, topCursPosExecutionStatus;
        public static int leftCursPosMainOutput, topCursPosMainOutput;
        public static int lastLeftCursorPosForSections, lastTopCursorPosForSections;
        //public static List<string> lszOutputBuffer = new List<string>();

        public static void InitializeConsole()
        {
            Console.Clear();
            Console.SetWindowSize(100, 40);
            Console.BufferWidth = 300;
            Console.BufferHeight = 400;
            Console.Title = "NHLA Importer Utility";
            Console.WriteLine("NHLA Importer Utility 1.0");
            Console.WriteLine("Copyright (c) 2010 Produce Reporter Co.");
            Console.WriteLine("All Rights Reserved.");
            Console.WriteLine("OS Version: " + System.Environment.OSVersion.ToString());
            Console.WriteLine("CLR Version: " + System.Environment.Version.ToString());
            Console.WriteLine(string.Empty);
            Console.WriteLine(string.Empty);

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

        public static void WriteCurrentCompanyScanned(int counter)
        {
            Console.SetCursorPosition(leftCursPosTotalCompImported, topCursPosTotalCompImported);

            leftCursPosTotalCompImported = Console.CursorLeft;
            topCursPosTotalCompImported = Console.CursorTop;

            Console.WriteLine(counter);
            Console.SetCursorPosition(leftCursPosTotalCompImported, topCursPosTotalCompImported);
        }

        public static void WriteCompanyScannedText()
        {
            Console.WriteLine();
            Console.WriteLine("Total Analysis");
            Console.WriteLine("---------------------------------------------------------");
            Console.Write("Total Companies: ");

            leftCursPosTotalCompImported = Console.CursorLeft;
            topCursPosTotalCompImported = Console.CursorTop;

            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine();

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

        public static void WriteTotalAnalysis(int totalImported)
        {
            Console.SetCursorPosition(leftCursPosTotalCompImported, topCursPosTotalCompImported);
            Console.WriteLine();
            Console.WriteLine("Total Companies Inserted: " + totalImported);

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

        public static void WriteSectionData(string message, int sectionCompaniesScanned, int sectionCompaniesInserted)
        {
            Console.SetCursorPosition(lastLeftCursPos, lastTopCursPos);
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine(message);
            Console.WriteLine("---------------------------------------------------------");
            Console.WriteLine("Companies Scanned: " + sectionCompaniesScanned);
            Console.WriteLine("Companies Inserted: " + sectionCompaniesInserted);

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;

            lastLeftCursorPosForSections = Console.CursorLeft;
            lastTopCursorPosForSections = Console.CursorTop;
        }

        public static void WriteDataIssues(List<DataIssue> dataIssues)
        {
            Console.SetCursorPosition(lastLeftCursorPosForSections, lastTopCursorPosForSections);
            Console.WriteLine();
            Console.WriteLine();
            Console.WriteLine("Data Issues Found");
            Console.WriteLine("---------------------------------------------------------");

            var sortedIssues = from issue in dataIssues
                                orderby issue.Type
                                select issue;

            foreach (DataIssue dataIssue in sortedIssues)
                Console.WriteLine(dataIssue.Issue);

            lastLeftCursPos = Console.CursorLeft;
            lastTopCursPos = Console.CursorTop;
        }

    }
}

