//using System.Text;

//namespace MilkOUT_API.Middleware
//{
//    public class MiddlewareRequstResponse
//    {
//        private readonly RequestDelegate _next;

//        public MiddlewareRequstResponse(RequestDelegate next)
//        {
//            _next = next;
//        }

//        public async Task InvokeAsync(HttpContext context)
//        {
//            context.Request.EnableBuffering();
//            var stream = context.Request.Body;


//            try
//            {
//                if (context.Request.Path == "v1/api/admin/crate/")
//                {
                    
//                }
//            }
//            catch (Exception e)
//            {
//                Console.WriteLine(e.Message);
//            }
//            context.Request.Body = stream;
//            await _next(context);
//        }
//    }
//}
