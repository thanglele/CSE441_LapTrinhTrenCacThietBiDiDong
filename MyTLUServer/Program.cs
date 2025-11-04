using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using System.Text;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Application.Services;
using MyTLUServer.Infrastructure.Data;

var builder = WebApplication.CreateBuilder(args);

if(builder.Environment.IsDevelopment() == true)
{
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("DevelopConnection")));
}
else
{
    builder.Services.AddDbContext<AppDbContext>(options => options.UseSqlServer(builder.Configuration.GetConnectionString("PublishConnection")));
}    

// *** THÊM MỤC 2: ĐĂNG KÝ MEMORY CACHE VÀ CÁC DỊCH VỤ ***
builder.Services.AddMemoryCache();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IEmailService, SmtpEmailService>();
builder.Services.AddScoped<IAttendanceService, AttendanceService>();
builder.Services.AddScoped<IGeoIpService, MockGeoIpService>();
builder.Services.AddScoped<IDeanService, DeanService>();
builder.Services.AddScoped<IFileStorageService, LocalStorageService>();
builder.Services.AddHttpContextAccessor();

builder.Services.AddScoped<ISessionService, SessionService>();

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddHttpClient<IFaceRecognitionService, FaceRecognitionService>(client =>
{
    // Đọc BaseUrl từ appsettings.json
    string baseUrl = builder.Configuration.GetSection("FaceRecService:BaseUrl").Value;
    if (string.IsNullOrEmpty(baseUrl))
    {
        throw new InvalidOperationException("FaceRecService:BaseUrl is not configured in appsettings.json");
    }
    client.BaseAddress = new Uri(baseUrl);
    client.Timeout = TimeSpan.FromSeconds(30); // Đặt timeout
});

// 3. Cấu hình Swagger
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo { Title = "MyTLU API", Version = "v1" });
    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please enter JWT with Bearer into field",
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            new string[] {}
        }
    });
});

// 4. Cấu hình JWT Authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]))
        };
    });

// 5. Cấu hình CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder => builder.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader());
});


var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

app.UseCors("AllowAll");

// 6. Kích hoạt Authentication và Authorization
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();