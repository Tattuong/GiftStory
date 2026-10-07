import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class GiftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const GiftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5C3140).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? Padding(padding: padding, child: child)
            : InkWell(
                onTap: onTap,
                child: Padding(padding: padding, child: child),
              ),
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  final String name;
  final int tone;
  final double size;

  const PersonAvatar({
    super.key,
    required this.name,
    required this.tone,
    this.size = 56,
  });

  static const _fills = [
    Color(0xFFF3D5C8),
    Color(0xFFE7D7C1),
    Color(0xFFE4C9D4),
    Color(0xFFD9D3C7),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PortraitPainter(tone % _fills.length),
      ),
    );
  }
}

class GiftPicture extends StatelessWidget {
  final String title;
  final double height;
  final bool showHeart;

  const GiftPicture({
    super.key,
    required this.title,
    this.height = 120,
    this.showHeart = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = _pictureStyle(title);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _GiftArtPainter(style)),
            if (showHeart)
              const Positioned(
                top: 8,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(Icons.favorite_border,
                        size: 16, color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _pictureStyle(String title) {
  final text = title.toLowerCase();
  if (text.contains('ceramic')) return 'ceramic';
  if (text.contains('notebook') || text.contains('journal')) return 'notebook';
  if (text.contains('mug') || text.contains('cup')) return 'floral';
  return 'gift';
}

IconData iconForLike(String like) {
  final text = like.toLowerCase();
  if (text.contains('hand')) return Icons.back_hand_outlined;
  if (text.contains('home') || text.contains('cozy')) {
    return Icons.cottage_outlined;
  }
  if (text.contains('station') || text.contains('paper')) {
    return Icons.menu_book_outlined;
  }
  if (text.contains('tea') || text.contains('coffee')) {
    return Icons.coffee_outlined;
  }
  if (text.contains('minimal')) return Icons.diamond_outlined;
  if (text.contains('book')) return Icons.auto_stories_outlined;
  if (text.contains('outdoor') || text.contains('walk')) {
    return Icons.park_outlined;
  }
  if (text.contains('cook')) return Icons.restaurant_outlined;
  if (text.contains('scarf') || text.contains('cloth')) {
    return Icons.checkroom_outlined;
  }
  if (text.contains('flower')) return Icons.local_florist_outlined;
  if (text.contains('tool')) return Icons.handyman_outlined;
  if (text.contains('jazz') || text.contains('music')) {
    return Icons.music_note_outlined;
  }
  return Icons.favorite_border;
}

class _PortraitPainter extends CustomPainter {
  final int tone;

  _PortraitPainter(this.tone);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromLTWH(0, 0, s, s)));
    switch (tone) {
      case 0:
        _maya(canvas, s);
        break;
      case 1:
        _alex(canvas, s);
        break;
      case 2:
        _mom(canvas, s);
        break;
      default:
        _dad(canvas, s);
    }
    canvas.restore();
  }

  void _maya(Canvas canvas, double s) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFFF8E4DC));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.46),
          width: s * 0.86,
          height: s * 0.98),
      Paint()..color = const Color(0xFF3A2924),
    );
    _face(canvas, s, const Color(0xFFF3C4A8));
    final bangs = Path()
      ..moveTo(s * 0.24, s * 0.36)
      ..quadraticBezierTo(s * 0.40, s * 0.18, s * 0.62, s * 0.28)
      ..quadraticBezierTo(s * 0.78, s * 0.16, s * 0.82, s * 0.40)
      ..quadraticBezierTo(s * 0.66, s * 0.34, s * 0.52, s * 0.40)
      ..quadraticBezierTo(s * 0.38, s * 0.32, s * 0.24, s * 0.36);
    canvas.drawPath(bangs, Paint()..color = const Color(0xFF3A2924));
    _eyes(canvas, s);
    _smile(canvas, s);
    _shirt(canvas, s, const Color(0xFFE7A3B6));
    _heart(
        canvas, Offset(s * 0.78, s * 0.18), s * 0.07, const Color(0xFFE45B78));
  }

  void _alex(Canvas canvas, double s) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFFE7F0E4));
    final hair = Paint()..color = const Color(0xFF6A4632);
    for (final spot in const [
      [0.28, 0.28],
      [0.42, 0.20],
      [0.58, 0.20],
      [0.74, 0.30],
      [0.22, 0.42],
      [0.80, 0.44],
    ]) {
      canvas.drawCircle(Offset(s * spot[0], s * spot[1]), s * 0.13, hair);
    }
    _face(canvas, s, const Color(0xFFE8B892));
    _eyes(canvas, s);
    _smile(canvas, s);
    _shirt(canvas, s, const Color(0xFF7E9A74));
  }

  void _mom(Canvas canvas, double s) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFFF6E7DA));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.42),
          width: s * 0.92,
          height: s * 0.78),
      Paint()..color = const Color(0xFFC9B7AE),
    );
    canvas.drawCircle(Offset(s * 0.24, s * 0.48), s * 0.10,
        Paint()..color = const Color(0xFFD5C4BC));
    canvas.drawCircle(Offset(s * 0.78, s * 0.46), s * 0.11,
        Paint()..color = const Color(0xFFD5C4BC));
    _face(canvas, s, const Color(0xFFF0C3A4));
    _eyes(canvas, s);
    _smile(canvas, s);
    _shirt(canvas, s, const Color(0xFFE7D0BE));
  }

  void _dad(Canvas canvas, double s) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, s, s), Paint()..color = const Color(0xFFF3E7DA));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.34),
          width: s * 0.72,
          height: s * 0.42),
      Paint()..color = const Color(0xFF2C241F),
    );
    _face(canvas, s, const Color(0xFFE7B48E));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.62),
          width: s * 0.34,
          height: s * 0.28),
      Paint()..color = const Color(0xFF3A2C26),
    );
    _eyes(canvas, s);
    final glasses = Paint()
      ..color = const Color(0xFF3A2C26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018;
    canvas.drawCircle(Offset(s * 0.41, s * 0.46), s * 0.075, glasses);
    canvas.drawCircle(Offset(s * 0.59, s * 0.46), s * 0.075, glasses);
    canvas.drawLine(
        Offset(s * 0.485, s * 0.46), Offset(s * 0.515, s * 0.46), glasses);
    _shirt(canvas, s, const Color(0xFF3E4C5C));
  }

  void _face(Canvas canvas, double s, Color color) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(s * 0.50, s * 0.48),
          width: s * 0.48,
          height: s * 0.52),
      Paint()..color = color,
    );
    canvas.drawCircle(Offset(s * 0.38, s * 0.54), s * 0.035,
        Paint()..color = const Color(0x33E07A78));
    canvas.drawCircle(Offset(s * 0.63, s * 0.54), s * 0.035,
        Paint()..color = const Color(0x33E07A78));
  }

  void _eyes(Canvas canvas, double s) {
    final paint = Paint()..color = const Color(0xFF3A2A28);
    canvas.drawCircle(Offset(s * 0.42, s * 0.46), s * 0.018, paint);
    canvas.drawCircle(Offset(s * 0.58, s * 0.46), s * 0.018, paint);
  }

  void _smile(Canvas canvas, double s) {
    final path = Path()
      ..moveTo(s * 0.44, s * 0.56)
      ..quadraticBezierTo(s * 0.50, s * 0.62, s * 0.56, s * 0.56);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC46A62)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.016
        ..strokeCap = StrokeCap.round,
    );
  }

  void _shirt(Canvas canvas, double s, Color color) {
    final path = Path()
      ..moveTo(0, s)
      ..lineTo(0, s * 0.80)
      ..quadraticBezierTo(s * 0.50, s * 0.66, s, s * 0.80)
      ..lineTo(s, s)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _heart(Canvas canvas, Offset center, double r, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + r)
      ..cubicTo(center.dx - r * 1.7, center.dy + r * 0.2, center.dx - r * 0.8,
          center.dy - r, center.dx, center.dy - r * 0.25)
      ..cubicTo(center.dx + r * 0.8, center.dy - r, center.dx + r * 1.7,
          center.dy + r * 0.2, center.dx, center.dy + r)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PortraitPainter oldDelegate) =>
      oldDelegate.tone != tone;
}

class _GiftArtPainter extends CustomPainter {
  final String style;

  _GiftArtPainter(this.style);

  @override
  void paint(Canvas canvas, Size size) {
    switch (style) {
      case 'ceramic':
        _ceramic(canvas, size);
        break;
      case 'notebook':
        _notebook(canvas, size);
        break;
      case 'floral':
        _floral(canvas, size);
        break;
      default:
        _gift(canvas, size);
    }
  }

  void _ceramic(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE7D2BE), Color(0xFFC6A07E)],
        ).createShader(rect),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(size.width * 0.18, size.height * 0.28),
          width: size.width * 0.28,
          height: size.height * 0.22),
      Paint()..color = const Color(0xFF8EAF86),
    );
    _mug(canvas, size, const Color(0xFFF4EFE6), const Color(0xFF5C463C),
        'Good\nPeople\nBrighter\nDays');
  }

  void _floral(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF7F1EA));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.08, size.height * 0.62, size.width * 0.84,
            size.height * 0.16),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFFE7D7C4),
    );
    _mug(canvas, size, Colors.white, const Color(0xFF7A2346), '');
    final flower = Paint()..color = const Color(0xFFE7A0B0);
    final leaf = Paint()..color = const Color(0xFF8EAF86);
    canvas.drawCircle(Offset(size.width * 0.42, size.height * 0.48),
        size.width * 0.035, flower);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.42),
        size.width * 0.03, flower);
    canvas.drawCircle(Offset(size.width * 0.58, size.height * 0.52),
        size.width * 0.028, leaf);
  }

  void _mug(Canvas canvas, Size size, Color body, Color ink, String label) {
    final mug = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.22, size.width * 0.40,
          size.height * 0.52),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(mug, Paint()..color = body);
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.60, size.height * 0.34, size.width * 0.16,
          size.height * 0.24),
      -1.2,
      2.4,
      false,
      Paint()
        ..color = const Color(0xFFD9CBBC)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.025,
    );
    if (label.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: ink,
          fontSize: size.width * 0.045,
          height: 1.15,
          fontWeight: FontWeight.w600,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.32);
    painter.paint(
      canvas,
      Offset(size.width * 0.32, size.height * 0.32),
    );
  }

  void _notebook(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF4EFE6));
    final book = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.12, size.width * 0.58,
          size.height * 0.76),
      const Radius.circular(8),
    );
    canvas.drawRRect(book, Paint()..color = const Color(0xFFFFFBF6));
    final ring = Paint()..color = const Color(0xFFD7C4B0);
    for (var i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.22, size.height * (0.24 + i * 0.12)),
        size.width * 0.018,
        ring,
      );
    }
    final painter = TextPainter(
      text: TextSpan(
        text: 'Good Ideas\nBrighter\nDays',
        style: TextStyle(
          color: const Color(0xFF7A4A58),
          fontSize: size.width * 0.075,
          height: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.40);
    painter.paint(canvas, Offset(size.width * 0.30, size.height * 0.28));
    canvas.save();
    canvas.translate(size.width * 0.78, size.height * 0.55);
    canvas.rotate(-0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-6, -28, 12, 56), const Radius.circular(6)),
      Paint()..color = const Color(0xFF2C2C2C),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -34, 10, 12), const Radius.circular(3)),
      Paint()..color = const Color(0xFFE7A0B0),
    );
    canvas.restore();
  }

  void _gift(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFF8E7EE));
    final box = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.58),
          width: size.width * 0.42,
          height: size.height * 0.36),
      const Radius.circular(8),
    );
    canvas.drawRRect(box, Paint()..color = const Color(0xFF7A2346));
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.58),
          width: size.width * 0.06,
          height: size.height * 0.36),
      Paint()..color = const Color(0xFFF8E7EE),
    );
  }

  @override
  bool shouldRepaint(covariant _GiftArtPainter oldDelegate) =>
      oldDelegate.style != style;
}

class WineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const WineButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

class DayBadge extends StatelessWidget {
  final String label;

  const DayBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coralSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
