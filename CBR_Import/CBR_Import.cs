using System.Configuration;
using System.ServiceProcess;
using System.Timers;

namespace CBR_Import
{
    public partial class CBR_Import : ServiceBase
    {
        Timer timer;
        public CBR_Import()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            Logger.WriteLog("Служба стартовала");
            this.timer = new System.Timers.Timer(setInterval(ConfigurationManager.AppSettings["timeInterval"]));
            this.timer.AutoReset = true;
            this.timer.Elapsed += new System.Timers.ElapsedEventHandler(this.timer_Elapsed);
            this.timer.Start();
        }

        private int setInterval(string interval)
        {
            int timeInterval;
            if (!int.TryParse(ConfigurationManager.AppSettings["timeInterval"], out timeInterval))
            {
                timeInterval = 86400000; // 24*60*60*1000
                Logger.WriteLog("Интервал времени сконфигурирован некорректно. Установлено значение по умолчанию - раз в сутки.");
            }
            return timeInterval;
        }

        protected override void OnStop()
        {
            this.timer.Stop();
            this.timer = null;
            Logger.WriteLog("Служба остановлена");
        }
        protected override void OnPause()
        {
            Logger.WriteLog("Служба поставлена на паузу");
        }

        protected override void OnContinue()
        {
            Logger.WriteLog("Служба продолжает работу");
        }
        private void timer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
        {
            ServiceWork.Main();
        }
    }
}
