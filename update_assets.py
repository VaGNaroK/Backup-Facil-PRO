import os

# 1. Update src/main.py
with open("src/main.py", "r") as f:
    content = f.read()
content = content.replace('get_asset_path("icon.png")', 'get_asset_path("icons/icon.png")')
with open("src/main.py", "w") as f:
    f.write(content)

# 2. Update scripts/gerar_deb.sh
with open("scripts/gerar_deb.sh", "r") as f:
    content = f.read()
content = content.replace('assets/icon.png', 'assets/icons/icon.png')
with open("scripts/gerar_deb.sh", "w") as f:
    f.write(content)

# 3. Update scripts/gerar_exe.bat
with open("scripts/gerar_exe.bat", "r") as f:
    content = f.read()
content = content.replace('--icon="assets\\icon.ico"', '--icon="assets\\icons\\icon.ico"')
content = content.replace('--icon="assets/icon.png"', '--icon="assets\\icons\\icon.ico"')
with open("scripts/gerar_exe.bat", "w") as f:
    f.write(content)

# 4. Update io.github.vagnarok.BackupFacilPro.yml
with open("io.github.vagnarok.BackupFacilPro.yml", "r") as f:
    content = f.read()
content = content.replace('assets/icon.png', 'assets/icons/icon.png')
with open("io.github.vagnarok.BackupFacilPro.yml", "w") as f:
    f.write(content)

# 5. Update src/ui_components.py to play sound
with open("src/ui_components.py", "r") as f:
    content = f.read()

# Add QtMultimedia imports if not exist
if "from PySide6.QtMultimedia import QSoundEffect" not in content:
    content = content.replace(
        "from PySide6.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,",
        "from PySide6.QtMultimedia import QSoundEffect\nfrom PySide6.QtCore import QUrl\nimport os, sys\nfrom PySide6.QtWidgets import (QWidget, QVBoxLayout, QHBoxLayout, QLabel, QLineEdit,"
    )

sound_logic = """    def backup_concluido(self, resultado):
        self.resetar_interface()
        msg_sucesso = resultado[0] if isinstance(resultado, tuple) else str(resultado)
        self.texto_status.setText("✅ Backup Finalizado!")
        self.novo_log.emit(f"✅ SUCESSO: {msg_sucesso}")
        
        # Toca o som de conclusão
        try:
            if getattr(sys, 'frozen', False):
                base_dir = sys._MEIPASS
            else:
                base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
            sound_path = os.path.join(base_dir, "assets", "sounds", "done.wav")
            if os.path.exists(sound_path):
                self.som_ok = QSoundEffect()
                self.som_ok.setSource(QUrl.fromLocalFile(sound_path))
                self.som_ok.setVolume(1.0)
                self.som_ok.play()
        except Exception as e:
            print(f"Erro ao tocar som: {e}")

        QMessageBox.information(self, "Sucesso", msg_sucesso)"""

old_backup_concluido = """    def backup_concluido(self, resultado):
        self.resetar_interface()
        msg_sucesso = resultado[0] if isinstance(resultado, tuple) else str(resultado)
        self.texto_status.setText("✅ Backup Finalizado!")
        self.novo_log.emit(f"✅ SUCESSO: {msg_sucesso}")
        QMessageBox.information(self, "Sucesso", msg_sucesso)"""

content = content.replace(old_backup_concluido, sound_logic)

with open("src/ui_components.py", "w") as f:
    f.write(content)

