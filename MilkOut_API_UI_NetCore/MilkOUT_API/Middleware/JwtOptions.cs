using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace Middleware
{
    public class JwtOptions
    {
        public string Secret { get; set; }
        public int ExpiryMinutes { get; set; }
    }

    public class RefreshToken
    {
        public string User_Id { get; set; }
        public string Token { get; set; }
        public string Ip_Address { get; set; }
    }
}
