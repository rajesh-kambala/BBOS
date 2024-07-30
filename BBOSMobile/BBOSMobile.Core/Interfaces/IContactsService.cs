using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BBOSMobile.Core.Models;

namespace BBOSMobile.Core.Interfaces
{
    public interface IContactsService
    {
        void CreateContact(String[] contactinfo);

        bool CanCreateContact();

    }
}




