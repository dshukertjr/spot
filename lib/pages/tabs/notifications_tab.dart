import 'package:flutter/material.dart';
import 'package:spot/components/profile_image.dart';

class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        itemCount: 20,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (context, index) {
          return Row(
            children: [
              const ProfileImage(),
              const SizedBox(width: 16),
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      const TextSpan(
                          text:
                              '@actuallisaheather commented "Hey, this looks like the old house from my dreams. I used to live here and I loved it so much."'),
                      TextSpan(
                        text: ' 1h',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset('assets/images/like.png'),
              ),
            ],
          );
        },
      ),
    );
  }
}
