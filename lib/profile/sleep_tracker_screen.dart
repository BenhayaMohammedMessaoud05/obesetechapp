import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SleepTrackerScreen extends StatelessWidget {
  const SleepTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat.jm();
    final time = formatter.format(now);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0C26),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Good Evening"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          )
        ],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ready for a Restful Night?",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Sleep Cycle Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F47),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    time,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  CircularPercentIndicator(
                    radius: 90,
                    lineWidth: 18,
                    percent: 0.78,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: const Text(
                      "Sleep Cycle\nTap to view\ndetails",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    backgroundColor: Colors.grey[800]!,
                    progressColor: Colors.purpleAccent,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _SleepPhase(label: "Deep Sleep", value: "2h 15m", color: Colors.tealAccent),
                      _SleepPhase(label: "REM", value: "1h 45m", color: Colors.orangeAccent),
                      _SleepPhase(label: "Light Sleep", value: "3h 30m", color: Colors.blueAccent),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sleep Session
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F47),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sleep Session",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _TimeInfo(icon: Icons.nights_stay, label: "Bedtime", time: "10:30 PM"),
                      _TimeInfo(icon: Icons.wb_sunny, label: "Wake Up", time: "7:00 AM"),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start Sleep"),
                        onPressed: () {},
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.stop),
                        label: const Text("End Sleep"),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sleep Quality Insights
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F47),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sleep Quality Insights",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(width: 40, child: Text(day, style: const TextStyle(color: Colors.white))),
                          Expanded(
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  const Text(
                    "Your sleep quality was best on Saturday. Consider an earlier bedtime for improved deep sleep.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Smart Alarms
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F47),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Smart Alarms",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _AlarmBox(title: "Wake Up Alarm", time: "7:00 AM", icon: Icons.alarm),
                      _AlarmBox(title: "Sleep Reminder", time: "10:00 PM", icon: Icons.notifications),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add_alarm),
                    label: const Text("Set New Alarm"),
                    onPressed: () {},
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sleep Tips Placeholder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F47),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Sleep Tips",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _SleepPhase extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SleepPhase({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _TimeInfo({required this.icon, required this.label, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(time, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _AlarmBox extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const _AlarmBox({required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        Text(time, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
