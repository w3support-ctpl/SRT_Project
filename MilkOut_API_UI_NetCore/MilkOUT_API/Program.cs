using Middleware;
using Serilog;

var builder = WebApplication.CreateBuilder(args);


// Add CORS policy
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowSpecificOrigin", builder =>
    {
        builder.WithOrigins("http://127.0.0.1:5500") // Allow your web app origin
               .AllowAnyMethod()                   // Allow any HTTP method (GET, POST, etc.)
               .AllowAnyHeader()                   // Allow any HTTP headers
               .AllowCredentials();                // Allow credentials if needed

               builder.WithOrigins("https://uatmilkout.srthoratmilk.in") // Allow your web app origin
               .AllowAnyMethod()                   // Allow any HTTP method (GET, POST, etc.)
               .AllowAnyHeader()                   // Allow any HTTP headers
               .AllowCredentials();  
    });
});


// Add services to the container.
var logger = new LoggerConfiguration()
	.ReadFrom.Configuration(builder.Configuration)
	.Enrich.FromLogContext()
	.CreateLogger();
builder.Logging.ClearProviders();
builder.Logging.AddSerilog(logger);

builder.Services.AddControllers();
builder.Services.AddJwt(builder.Configuration);

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
//{
	app.UseSwagger();
	app.UseSwaggerUI();
//}


app.UseCors("AllowSpecificOrigin");

app.Use(async (context, next) =>
{
    if (context.Request.Method == "OPTIONS")
    {
        context.Response.Headers.Add("Access-Control-Allow-Origin", "http://127.0.0.1:5500");
        context.Response.Headers.Add("Access-Control-Allow-Origin", "https://uatmilkout.srthoratmilk.in");
        
        context.Response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        context.Response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, Authorization");
        context.Response.StatusCode = 200;
        return;
    }
    await next();
});

app.UseAuthorization();
//app.UseMiddleware<MiddlewareRequstResponse>();

app.MapControllers();

app.Run();
