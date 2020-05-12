using System.ServiceProcess;

namespace CBR_Import
{
    static class Program
    {
        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[]
            {
                new CBR_Import()
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}
