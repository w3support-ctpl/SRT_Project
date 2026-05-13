
using Microsoft.AspNetCore.Mvc;
public class Rootobject
{
    public string BankCountry { get; set; }
    public string BankInternalID { get; set; }
    public string BankName { get; set; }
    public string Region { get; set; }
    public string StreetName { get; set; }
    public string CityName { get; set; }
    public string SWIFTCode { get; set; }
    public string BankNetworkGrouping { get; set; }
    public bool IsMarkedForDeletion { get; set; }
    public string Bank { get; set; }
    public string Branch { get; set; }
    public string BankCategory { get; set; }
    public List<string> SAP__Messages { get; set; }
}

