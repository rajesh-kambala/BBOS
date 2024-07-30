using BBOSMobile.ServiceModels.Common;
using System;
using System.Collections.Generic;

namespace BBOSMobile.ServiceModels.Responses
{
    public class GetContactNotesResponse: ResponseBase
    {
        public List<Note> Notes { get; set; }
    }
}
