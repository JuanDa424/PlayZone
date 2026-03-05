// lib/screens/perfil_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:play_zone1/models/usuario.dart';
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
        backgroundColor: kCarbonBlack,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar sesión?',
            style: TextStyle(color: kWhite, fontWeight: FontWeight.bold)),
        content: const Text('Se cerrará tu sesión actual.',
            style: TextStyle(color: kLightGray)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: kLightGray)),
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
      color: kCarbonBlack,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar ───────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: kGreenNeon.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: kGreenNeon, width: 2),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: kGreenNeon,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.usuario.nombre,
              style: const TextStyle(
                color: kWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.usuario.correo,
              style: const TextStyle(color: kLightGray, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: kGreenNeon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kGreenNeon.withOpacity(0.3)),
              ),
              child: Text(
                widget.usuario.role,
                style: const TextStyle(
                  color: kGreenNeon,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Info personal ─────────────────────────────
            _SeccionTitulo(titulo: 'Información personal'),
            _InfoTile(
              icon: Icons.person_outline_rounded,
              label: 'Nombre',
              value: widget.usuario.nombre,
            ),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Correo',
              value: widget.usuario.correo,
            ),
            const SizedBox(height: 20),

            // ── Preferencias ──────────────────────────────
            _SeccionTitulo(titulo: 'Preferencias'),
            _ConfigTile(
              icon: Icons.language_rounded,
              label: 'Idioma',
              trailing: const Text('Español',
                  style: TextStyle(color: kLightGray, fontSize: 13)),
            ),
            _ConfigTile(
              icon: Icons.notifications_rounded,
              label: 'Notificaciones',
              trailing: Switch(
                value: _notificaciones,
                activeColor: kGreenNeon,
                onChanged: (v) => setState(() => _notificaciones = v),
              ),
            ),
            const SizedBox(height: 20),

            // ── Cuenta ───────────────────────────────────
            _SeccionTitulo(titulo: 'Cuenta'),
            _ConfigTile(
              icon: Icons.logout_rounded,
              label: 'Cerrar sesión',
              iconColor: Colors.redAccent,
              labelColor: Colors.redAccent,
              onTap: _cerrarSesion,
            ),
          ],
        ),
      ),
    );
  }
}

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
          style: const TextStyle(
            color: kLightGray,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
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

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kDarkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: kLightGray, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: kLightGray, fontSize: 11)),
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
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color labelColor;

  const _ConfigTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.iconColor = kLightGray,
    this.labelColor = kWhite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kDarkGray,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
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
              const Icon(Icons.chevron_right_rounded,
                  color: kLightGray, size: 20),
          ],
        ),
      ),
    );
  }
}