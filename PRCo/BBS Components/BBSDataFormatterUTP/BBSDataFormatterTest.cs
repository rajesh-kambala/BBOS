using System;
using System.Data;

using NUnit.Framework;

namespace PRCO.BBS
{
	/// <summary>
	/// Summary description for BBSDataFormatterTest.
	/// </summary>
	[TestFixture] 
	public class BBSDataFormatterTest
	{
        DataFormatter _oDataFormatter = null;

		public BBSDataFormatterTest() {}

		/// <summary>
		///  Helper method that checks for errors in
		///  the returned event string.
		/// </summary>
		/// <param name="szEventText"></param>
		protected void CheckForError(string szEventText) {
			Assert.IsNotNull(szEventText);
			Assert.IsFalse(szEventText.StartsWith("ERROR:"), "Error found: " + szEventText);
			System.Console.WriteLine(szEventText);
		}

        ///<summary>
        /// Get ready for some good ol'fashion testing...
        ///</summary>
        [TestFixtureSetUp]
        public void Init() {
            _oDataFormatter = new DataFormatter();
        }

		#region Business Event Tests
		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAquisition() {
            string szEventText = _oDataFormatter.GetBusinessEventText(50001);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAquisitionEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60001);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAquisitionOther() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50002);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAquisitionOtherEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60002);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAgreementInPrinciple() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50003);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAgreementInPrincipleEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60003);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAgreementInPrincipleOther() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50004);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAgreementInPrincipleOtherEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60004);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAssignmentBenefitCreditors() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50005);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventAssignmentBenefitCreditorsEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60005);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBankruptcy() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50006);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBankruptcyEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60006);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventUSBankruptcy() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50007);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventUSBankruptcyEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60007);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventCanadianBankruptcy() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50008);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventCanadianBankruptcyEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60008);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed88() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50009);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed88Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60009);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed108() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50010);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed108Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60010);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed113() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50011);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosed113Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60011);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosedInactive() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50012);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessClosedInactiveEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60012);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessEnityChangedUnderLaw() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50013);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessEnityChangedUnderLawEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60013);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessEnityChanged() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50014);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessEnityChangedEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60014);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessStartedUnderLaw() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50015);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessStartedUnderLawEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60015);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessStarted() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50016);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventBusinessStartedEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60016);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndividualOwnership() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50017);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndividualOwnershipEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60017);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDivestiture() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50018);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDivestitureEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60018);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue155() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50019);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue155Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60019);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue156() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50020);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue156Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60020);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue157() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50021);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue157Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60021);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue158() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50022);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventDRCIssue158Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60022);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise1() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50023);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise1Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60023);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise2() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50024);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise2Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60024);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise3() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50025);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise3Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60025);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise4() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50026);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise4Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60026);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise5() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50027);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise5Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60027);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise7() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50028);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventExtensionCompromise7Empty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60028);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventFinancialEvents() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50029);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventFinancialEventsEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60029);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndictment() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50030);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndictmentEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60030);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndictmentClosed() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50031);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventIndictmentClosedEmpty() {
			string szEventText = _oDataFormatter.GetBusinessEventText(60031);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventInjunction() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50032);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventJudgement() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50033);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventLetterOfIntent() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50034);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventLetterOfIntentOther() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50035);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventLien() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50036);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventLocationChange() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50037);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventMerger() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50038);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventNaturalDisaster() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50039);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventNaturalDisasterOther() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50040);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventNoProduce() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50041);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventOtherLegalAction() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50042);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventOther() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50043);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventOtherPACA() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50044);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPACALicenseSuspended_1() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50045);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPACALicenseSuspended_2() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50046);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPACALicenseReinstated() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50047);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPACATrustProcedure() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50048);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPartnershipDissolution() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50049);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventReceivershipAppliedFor() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50050);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventReceivershipAppointed() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50051);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventSECActions() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50052);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventPublicStock() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50053);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventTreasuryStock() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50054);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventTreasuryStockAmount() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50055);
			CheckForError(szEventText);
		}

		[Test]
		[Category("BusinessEvent")]
		public void TestBusinessEventTRO() {
			string szEventText = _oDataFormatter.GetBusinessEventText(50056);
			CheckForError(szEventText);
		}
		#endregion

		#region Person Event Tests
		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventDRCViolation() {
			string szEventText = _oDataFormatter.GetPersonEventText(50000);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventPACAViolation() {
            string szEventText = _oDataFormatter.GetPersonEventText(50001);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventEducation() {
            string szEventText = _oDataFormatter.GetPersonEventText(50002);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventBankruptcyFiled() {
            string szEventText = _oDataFormatter.GetPersonEventText(50003);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventBankruptcyDimissed() {
            string szEventText = _oDataFormatter.GetPersonEventText(50004);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventOtherLegalAction() {
            string szEventText = _oDataFormatter.GetPersonEventText(50005);
			CheckForError(szEventText);
		}

		[Test]
		[Category("PersonEvent")]
		public void TestPersonEventOther() {
            string szEventText = _oDataFormatter.GetPersonEventText(50006);
			CheckForError(szEventText);
		}
		#endregion
	}
}