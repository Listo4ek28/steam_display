import 'package:flutter/material.dart';

import 'config.dart';

// =====================================================================
// КАСТОМНЫЙ ОБРЕЗАТЕЛЬ УГЛА ДЛЯ ПЛАШЕК ИСТОРИИ
// =====================================================================
class HistoryClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width - 15, size.height);
    path.lineTo(size.width, size.height - 15); 
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// =====================================================================
// ВИДЖЕТ ОВЕРЛЕЯ НАСТРОЕК
// =====================================================================
class SettingsOverlay extends StatefulWidget {
  final String currentId;
  final List<String> recentIds;
  final Map<String, String> historyNicknames;
  
  // Новые поля для глитча
  final bool isGlitchEnabled;
  final ValueChanged<bool> onGlitchChanged;

  final Function(String) onIdSelected;
  final VoidCallback onClose;

  const SettingsOverlay({
    super.key,
    required this.currentId,
    required this.recentIds,
    required this.historyNicknames,
    required this.isGlitchEnabled,
    required this.onGlitchChanged,
    required this.onIdSelected,
    required this.onClose,
  });

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  final TextEditingController _inputController = TextEditingController();
  final Color colorNeonRed = const Color(0xFFFF0045);

  @override
  void initState() {
    super.initState();
    _inputController.text = widget.currentId;
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _submitId(String id) {
    if (id.trim().isNotEmpty) {
      widget.onIdSelected(id.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ВВЕДИТЕ STEAM ID64", style: TextStyle(color: colorNeonRed, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // Поле ввода
            SizedBox(
              width: 500,
              child: TextField(
                controller: _inputController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF4A0015),
                  border: OutlineInputBorder(borderSide: BorderSide(color: colorNeonRed)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorNeonRed, width: 2)),
                  hintText: "7656119...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.keyboard_return, color: colorNeonRed, size: 30),
                    onPressed: () => _submitId(_inputController.text),
                  ),
                ),
                onSubmitted: (value) => _submitId(value),
              ),
            ),

            // Чекбокс глитча
            const SizedBox(height: 15),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: widget.isGlitchEnabled,
                  onChanged: (val) {
                    if (val != null) widget.onGlitchChanged(val);
                  },
                  activeColor: colorNeonRed,
                  checkColor: Colors.black,
                ),
                const Text("Глитч аватара", style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            
            // ИСТОРИЯ ID В ВИДЕ СПИСКА ПЛАШЕК
            if (widget.recentIds.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text("ПОСЛЕДНИЕ АККАУНТЫ:", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 15),
              Container(
                width: 500,
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.recentIds.length,
                  itemBuilder: (context, index) {
                    String id = widget.recentIds[index];
                    String name = widget.historyNicknames[id] ?? "Загрузка...";
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          _inputController.text = id;
                          _submitId(id);
                        },
                        child: ClipPath(
                          clipper: HistoryClipPath(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorNeonRed.withOpacity(0.3),
                              border: Border.all(color: colorNeonRed, width: 2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(id, style: const TextStyle(color: Colors.white70, fontSize: 20)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            TextButton(
              onPressed: widget.onClose,
              child: const Text("ЗАКРЫТЬ", style: TextStyle(color: Colors.grey, fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}