using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SendGrid
{
    public class EmailValidationResult
    {
        public int BBID;
        public int PersonID;
        public string email;
        public string verdict;
        public decimal score;
        public string local;
        public string host;
        public string suggestion;
        public string source;
        public string ip_address;
        public Checks checks;
    }

    public class Checks
    {
        public Domain domain;
        public Local_part local_part;
        public Additional additional;
    }
    
    public class Domain
    {
        public bool has_valid_address_syntax;
        public bool has_mx_or_a_record;
        public bool is_suspected_disposable_address;
    }

    public class Local_part
    {
        public bool is_suspected_role_address;
    }

    public class Additional
    {
        public bool has_known_bounces;
        public bool has_suspected_bounces;
    }
}
