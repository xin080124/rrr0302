using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using System.Diagnostics;

namespace MyDrag
{
    public partial class Form1 : Form
    {
        private System.Windows.Forms.ListBox SourceList;

        public Form1()
        {
            InitializeComponent();
        }

        private void panel1_DragDrop(object sender, DragEventArgs e)
        {

        }

        private void panel1_DragEnter(object sender, DragEventArgs e)
        {

        }

        private void listBox1_MouseDown(object sender, MouseEventArgs e)
        {
            Debug.WriteLine(" enter listBox1_MouseDown ");
            ListBox box = (sender as ListBox);
            SourceList = box; //store the box the drag began in with a global reference

            //find the line we are dragging in the textbox
            int index = box.IndexFromPoint(e.X, e.Y);

            DragDropEffects result = box.DoDragDrop(box.Items[index], DragDropEffects.All);

            //the next lines do not run until the drop is completed
            //if ((rbMove.Checked) && (result != DragDropEffects.None))
            if(result != DragDropEffects.None)
            {
                //box.Items.RemoveAt(index);
                Debug.WriteLine(" output ");

            }
        }
    }
}

namespace MyDate
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            initialTime();
        }

        private void dateTimePicker1_ValueChanged(object sender, EventArgs e)
        {
//            DateTime t = DateTime.Now;
 //           textBox1.Text = t.AddDays(-2).ToString();

            DateTime bDate = (dateTimePicker1.Value).AddDays(364);
            dateTimePicker2.Value = bDate;

            //?????????leap year
            //txtDay.Text = bDate.Day.ToString();
            //label3.Text = bDate.ToString();
        }

        private DateTime FindNextSunday(DateTime aDate)
        {
            DateTime d;
            if (aDate.DayOfWeek == System.DayOfWeek.Sunday)
                d = aDate.AddDays(7);
            else
                d = aDate.AddDays((7-Convert.ToDouble(aDate.DayOfWeek)));
            return d;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            DateTime selector1_time = dateTimePicker1.Value;
            DateTime nextSunday = FindNextSunday(selector1_time);
            textBox1.Text = nextSunday.ToString();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            DateTime d = dateTimePicker1.Value;
            DateTime s;
            string sundaystr = "";
            while (d < dateTimePicker2.Value)
            {
                s = FindNextSunday(d);
                sundaystr += "\r"+s.ToString();
                d = s; 
            }
            textBox1.Text = sundaystr;
        }

        
        private void initialTime()
        {
            //DateTime aDate = DateTime.Now;
            DateTime bDate = (dateTimePicker1.Value).AddDays(364);
            dateTimePicker2.Value = bDate;
        }
        

    }
}

