namespace sstchur.web.survey
{
    using System;
    using System.Web.UI.WebControls;

    public class ListControlValidator : BaseValidator
    {
        protected override bool ControlPropertiesValid()
        {
            return true;
        }

        protected override bool EvaluateIsValid()
        {
            ListControl control = (ListControl) this.FindControl(base.ControlToValidate);						
            return (control.SelectedIndex != -1);
        }
    }
}

