using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MilIn_DayEnd_Jobs.Models
{

    public class ResMaterials
    {
        public string? org_id { get; set; }
        public string? formatted_date { get; set; }
        public string? date { get; set; }
        public string? method_name { get; set; }
    }

    public class CommonOutput
    {
        public int result_id { get; set; }
        public string? result_description { get; set; }
        public string? result_extra_key { get; set; }
    }


}
