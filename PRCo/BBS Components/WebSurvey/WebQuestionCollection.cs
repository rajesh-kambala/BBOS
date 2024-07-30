namespace sstchur.web.survey
{
    using System;
    using System.Collections.Specialized;
    using System.Reflection;

    public class WebQuestionCollection : NameValueCollection
    {
        public void Add(WebQuestion wq)
        {
            base.BaseAdd(wq.Id, wq);
        }

        public WebQuestion this[int index]
        {
            get
            {
                return (WebQuestion) base.BaseGet(index);
            }
            set
            {
                base.BaseSet(index, value);
            }
        }

        public WebQuestion this[string key]
        {
            get
            {
                return (WebQuestion) base.BaseGet(key);
            }
            set
            {
                base.BaseSet(key, value);
            }
        }
    }
}

