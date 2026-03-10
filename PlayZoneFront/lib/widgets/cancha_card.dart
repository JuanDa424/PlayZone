// lib/widgets/cancha_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/cancha.dart';
import '../util/constants.dart';

class CanchaCard extends StatefulWidget {
  final Canchas cancha;
  final VoidCallback onTap;
  final int index;

  const CanchaCard({
    super.key,
    required this.cancha,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<CanchaCard> createState() => _CanchaCardState();
}

class _CanchaCardState extends State<CanchaCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disponible = widget.cancha.disponibilidad;
    final accentColor = disponible ? kGreenNeon : Colors.redAccent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _pressed
                  ? accentColor.withOpacity(0.5)
                  : accentColor.withOpacity(0.15),
              width: 1.2,
            ),
            boxShadow: disponible
                ? [
                    BoxShadow(
                      color: kGreenNeon.withOpacity(_pressed ? 0.2 : 0.08),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : kCardShadow,
          ),
          child: Row(
            children: [
              // ── Imagen / Ícono ────────────────────────
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: disponible
                        ? [
                            kGreenNeon.withOpacity(0.12),
                            kGreenNeon.withOpacity(0.04),
                          ]
                        : [
                            Colors.redAccent.withOpacity(0.12),
                            Colors.redAccent.withOpacity(0.04),
                          ],
                  ),
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(18)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow circle detrás del ícono
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withOpacity(0.08),
                      ),
                    ),
                    Icon(
                      Icons.sports_soccer_rounded,
                      size: 36,
                      color: accentColor.withOpacity(0.7),
                    ),
                  ],
                ),
              ),

              // ── Info ──────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cancha.nombre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: kWhite,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Badge disponibilidad
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: accentColor.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dot pulsante
                            _PulseDot(color: accentColor,
                                active: disponible),
                            const SizedBox(width: 6),
                            Text(
                              disponible ? 'Disponible' : 'No disponible',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),

              // ── Flecha ────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _pressed
                        ? accentColor.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: _pressed ? accentColor : kLightGray,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (widget.index * 80).ms, duration: 400.ms)
        .slideY(begin: 0.15);
  }
}

// ── Dot pulsante para disponible ──────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  final bool active;
  const _PulseDot({required this.color, required this.active});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.active) _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
          width: 7, height: 7,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: widget.color));
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(_anim.value),
        ),
      ),
    );
  }
}