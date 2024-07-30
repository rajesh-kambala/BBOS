using System.ComponentModel;
using System.Drawing;
using System.Windows.Forms;

namespace OKSLeadsImportUI
{
    public class TextProgressBar : ProgressBar
    {
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams cp = base.CreateParams;
                cp.ExStyle |= 0x02000000;
                // Turn on WS_EX_COMPOSITED    
                return cp;
            }
        }

        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);
            if (m.Msg == 0x000F)
            {
                using (Graphics graphics = CreateGraphics())
                using (SolidBrush brush = new SolidBrush(ForeColor))
                {
                    SizeF textSize = graphics.MeasureString(Text, SystemFonts.DefaultFont);
                    graphics.DrawString(Text, SystemFonts.DefaultFont, brush, (Width - textSize.Width) / 2, (Height - textSize.Height) / 2);
                }
            }
        }

        [EditorBrowsable(EditorBrowsableState.Always)]
        [Browsable(true)]
        public override string Text
        {
            get
            {
                return base.Text;
            }
            set
            {
                base.Text = value;
                Refresh();
            }
        }
    }
}