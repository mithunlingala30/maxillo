import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';

class _NotificationItem {
  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String subtitle;
  final String time;
  const _NotificationItem(this.icon, this.color, this.bg, this.title, this.subtitle, this.time);
}

const _items = [
  _NotificationItem(Icons.check_circle_outline, AppColors.success, AppColors.successBg,
      'Prediction Completed', 'Your AI soft tissue prediction is ready to view.', '2h ago'),
  _NotificationItem(Icons.picture_as_pdf_outlined, AppColors.primaryBlue, AppColors.blueBg,
      'Report Generated', 'Your PDF medical report has been generated.', '2h ago'),
  _NotificationItem(Icons.favorite_border, AppColors.teal, AppColors.tealBg,
      'Recovery Reminder', "Time to log today's recovery check-in.", '1d ago'),
  _NotificationItem(Icons.event_available_outlined, AppColors.purple, AppColors.purpleBg,
      'Follow-up Reminder', 'Your follow-up consultation is in 3 days.', '2d ago'),
  _NotificationItem(Icons.campaign_outlined, AppColors.warning, AppColors.warningBg,
      'Important Update', 'MaxilloAI model has been updated for improved accuracy.', '5d ago'),
];

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        titleTextStyle: const TextStyle(color: AppColors.heading, fontWeight: FontWeight.w700, fontSize: 17),
        iconTheme: const IconThemeData(color: AppColors.heading),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _items.length,
        itemBuilder: (context, i) {
          final item = _items[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SoftCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(12)),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text(item.subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.subText)),
                      ],
                    ),
                  ),
                  Text(item.time, style: const TextStyle(fontSize: 10.5, color: AppColors.placeholder)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
