// using Middleware;
// using Serilog;

// var builder = WebApplication.CreateBuilder(args);

// // Add services to the container.
// var logger = new LoggerConfiguration()
// 	.ReadFrom.Configuration(builder.Configuration)
// 	.Enrich.FromLogContext()
// 	.CreateLogger();
// builder.Logging.ClearProviders();
// builder.Logging.AddSerilog(logger);

// builder.Services.AddControllers();
// builder.Services.AddJwt(builder.Configuration);

// // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
// builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();

// var app = builder.Build();

// // Configure the HTTP request pipeline.
// //if (app.Environment.IsDevelopment())
// //{
// 	app.UseSwagger();
// 	app.UseSwaggerUI();
// //}

// app.UseAuthorization();

// app.MapControllers();

// app.Run();
using Middleware;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
var logger = new LoggerConfiguration()
	.ReadFrom.Configuration(builder.Configuration)
	.Enrich.FromLogContext()
	.CreateLogger();
builder.Logging.ClearProviders();
builder.Logging.AddSerilog(logger);

builder.Services.AddControllers();
builder.Services.AddJwt(builder.Configuration);

// CORS Policy to allow all origins, methods, and headers
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

// Swagger/OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Enable Swagger in all environments
app.UseSwagger();
app.UseSwaggerUI();

// Enable CORS
app.UseCors("AllowAll");

app.UseAuthorization();

app.MapControllers();

app.Run();
