using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace example_bi_directional_provider_dotnet.core
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args) =>
          Host.CreateDefaultBuilder(args)
              .ConfigureWebHostDefaults(builder =>
              {
                  builder.UseStartup<Startup>().ConfigureLogging(loggingBuilder => loggingBuilder.ClearProviders());

                  builder.UseUrls("http://localhost:9000/");
                  builder.SuppressStatusMessages(true);
              });
    }
}
