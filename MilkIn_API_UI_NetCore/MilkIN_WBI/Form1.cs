using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using static System.Net.Mime.MediaTypeNames;
using System.Configuration;
using System.Diagnostics;
using System.Data.SqlClient;
using MySql.Data.MySqlClient;
using Dapper;
using System.Reflection;

// Machine1 = Tanker Weight
// Machine2 = Truck Weight
// Machine3 = Quality Entry

namespace MilkIN_WBI
{
    public partial class Form1 : Form
    {
        string LastUpdatedValue = "";

        string DefaultPath = System.Configuration.ConfigurationManager.AppSettings["DefaultPath"];
        string Environment = System.Configuration.ConfigurationManager.AppSettings["Environment"];
        string FieldName = System.Configuration.ConfigurationManager.AppSettings["FieldName"];
        string OrgId = System.Configuration.ConfigurationManager.AppSettings["OrgId"];
        private IDbConnection db;

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            string ConStr;
            switch (Environment)
            {
                case "Prd":
                    ConStr = "server=20.235.14.88; port=3306; database=d003_srtprd;userid=appuser;password=App@dmin#2024;";
                    break;
                case "Uat":
                    ConStr = "server=20.235.14.88; port=3306; database=d001_srtdev;userid=appuser;password=App@dmin#2024;";
                    break;
                default:
                    ConStr = "server=20.235.14.88; port=3306; database=d001_srtdev;userid=appuser;password=App@dmin#2024;";
                    break;
                    //server=20.235.14.88; port=3306; database=d001_srtdev;userid=appuser;password=App@dmin#2024;
            }
            db = new MySqlConnection(ConStr);
            statusL1.Text = "Env : " + Environment;
            statusL2.Text = "Type : " + FieldName;
            statusL3.Text = "Org Id : " + OrgId;
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            ReadWeight();
        }

        private void ReadWeight()
        {
            try
            {
                //using (FileStream fs = new FileStream(DefaultPath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                //{
                //    using (StreamReader sr = new StreamReader(fs))
                //    {
                //        while (sr.Peek() >= 0)  // reading the old data
                //        {
                //            string CurrentValue = sr.ReadLine();
                //        }
                //        sr.Close();
                //    }
                //}

                if (File.Exists(DefaultPath))
                {
                    // Read entire text file content in one string
                    string CurrentValue = File.ReadAllText(DefaultPath);
                    if (CurrentValue != LastUpdatedValue)
                    {
                        // Update data to Server
                        var parameters = new DynamicParameters(new
                        {
                            var_Org_Id = OrgId,
                            var_Method_Name = "Update",
                            var_Machine_Type = FieldName,
                            var_Machine_Value = CurrentValue
                        });


                        List<CommonOutput> resObj = this.db.Query<CommonOutput>("USP_AdminMachine_Set", parameters, commandType: CommandType.StoredProcedure).ToList();
                        if (resObj.Count > 0)
                        {
                            if (resObj[0].Result_Id == 1)
                            {
                                LastUpdatedValue = CurrentValue;
                                txtLog.Text = "Value Updated :" + CurrentValue;
                            }
                            else
                            {
                                // Add Error in Log
                                txtLog.Text = "Error :" + resObj[0].Result_Description;
                            }
                        }
                        else
                        {
                            // Add Error in Log
                            txtLog.Text = "Error : Value not updated";
                        }

                        

                    }

                } else
                {
                    txtLog.Text = "Error : File not found at location " + DefaultPath;
                }
            }
            catch (Exception ex)
            {

                txtLog.Text = ex.Message;
            }

            
        }

        public class CommonOutput
        {
            public int Result_Id { get; set; }
            public string Result_Description { get; set; }
            public string Result_Extra_Key { get; set; }
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            timer1.Start();
            btnStart.Enabled = false;
            btnStop.Enabled = true;
        }

        private void btnStop_Click(object sender, EventArgs e)
        {
            timer1.Stop();
            btnStart.Enabled = true;
            btnStop.Enabled = false;
            txtLog.Text = "Disconnected";
        }
    }
}
