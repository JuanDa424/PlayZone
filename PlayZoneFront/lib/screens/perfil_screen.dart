// lib/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:play_zone/models/usuario.dart';
import '../util/constants.dart';

class PerfilScreen extends StatefulWidget {
  final Usuario usuario;
  const PerfilScreen({super.key, required this.usuario});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _notificaciones = true;

  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar sesión?',
            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
        content: const Text('Se cerrará tu sesión actual.',
            style: TextStyle(color: kLightGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: kLightGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/');
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.usuario.nombre.isNotEmpty
        ? widget.usuario.nombre[0].toUpperCase()
        : '?';

    return Container(
      decoration: const BoxDecoration(gradient: kBgGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ───────────────────────────────────
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: kGreenGlow,
                    shape: BoxShape.circle,
                    boxShadow: kGreenShadow,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: kBorderColor, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: kLightGray, size: 13),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 14),

            Text(
              widget.usuario.nombre,
              style: const TextStyle(
                color: kWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

            const SizedBox(height: 4),

            Text(
              widget.usuario.correo,
              style: const TextStyle(color: kLightGray, fontSize: 14),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: kGreenGlow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.usuario.role,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 32),

            // ── Info personal ─────────────────────────────
            _SeccionTitulo(titulo: 'INFORMACIÓN PERSONAL'),
            _InfoTile(
              icon: Icons.person_outline_rounded,
              label: 'Nombre',
              value: widget.usuario.nombre,
              delay: 250,
            ),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Correo',
              value: widget.usuario.correo,
              delay: 300,
            ),

            const SizedBox(height: 20),

            // ── Preferencias ──────────────────────────────
            _SeccionTitulo(titulo: 'PREFERENCIAS'),
            _ConfigTile(
              icon: Icons.language_rounded,
              label: 'Idioma',
              delay: 350,
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kDarkGray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Español',
                    style: TextStyle(color: kLightGray, fontSize: 13)),
              ),
            ),
            _ConfigTile(
              icon: Icons.notifications_rounded,
              label: 'Notificaciones',
              delay: 400,
              trailing: Switch(
                value: _notificaciones,
                activeColor: kGreenNeon,
                activeTrackColor: kGreenNeon.withOpacity(0.3),
                inactiveThumbColor: kLightGray,
                inactiveTrackColor: kDarkGray,
                onChanged: (v) => setState(() => _notificaciones = v),
              ),
            ),

            const SizedBox(height: 20),

            // ── Cuenta ───────────────────────────────────
            _SeccionTitulo(titulo: 'CUENTA'),
            _ConfigTile(
              icon: Icons.lock_outline_rounded,
              label: 'Cambiar contraseña',
              delay: 450,
              onTap: () => context.go('/recuperar'),
            ),
            _ConfigTile(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              delay: 500,
              onTap: _cerrarSesion,
            ),

            const SizedBox(height: 32),

            // ── Versión ───────────────────────────────────
            Text(
              'PlayZone v1.0.0',
              style: TextStyle(
                  color: kLightGray.withOpacity(0.4), fontSize: 12),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────
class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titulo,
          style: TextStyle(
            color: kLightGray.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int delay;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kGreenNeon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kGreenNeon, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: kLightGray, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: kWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 350.ms).slideX(begin: -0.05);
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color labelColor;
  final int delay;

  const _ConfigTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor = kLightGray,
    this.labelColor = kWhite,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              Icon(Icons.chevron_right_rounded,
                  color: kLightGray.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms, duration: 350.ms).slideX(begin: -0.05);
  }
}