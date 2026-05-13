using LibreHardwareMonitor.Hardware;

namespace YourNamespace.Services
{
    public class SystemUsageService
    {
        private readonly Computer _computer;

        public SystemUsageService()
        {
            _computer = new Computer
            {
                IsCpuEnabled = true
            };
            _computer.Open();
        }

        public float GetCpuUsage()
        {
            float totalLoad = 0;
            int count = 0;

            foreach (var hardware in _computer.Hardware)
            {
                if (hardware.HardwareType == HardwareType.Cpu)
                {
                    hardware.Update();

                    foreach (var sensor in hardware.Sensors)
                    {
                        if (sensor.SensorType == SensorType.Load && sensor.Name == "CPU Total")
                        {
                            if (sensor.Value.HasValue)
                            {
                                totalLoad += sensor.Value.Value;
                                count++;
                            }
                        }
                    }
                }
            }

            return count > 0 ? totalLoad / count : 0;
        }
    }
}
