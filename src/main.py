import sys
import os
# pyrefly: ignore [missing-import]
from PySide6.QtWidgets import QApplication, QMainWindow, QWidget, QHBoxLayout, QListWidget, QStackedWidget
from PySide6.QtGui import QIcon
from PySide6.QtCore import Qt
from ui_components import AbaBackup, AbaDashboard, AbaRestauracao, AbaComparar, AbaLogs, AbaAgendamento, AbaSobre, AbaDuplicados, AbaVerificarHash, AbaExclusaoSegura, AbaRecuperacaoDados

# 🧭 GPS PARA IMAGENS
def get_asset_path(filename):
    if getattr(sys, 'frozen', False):
        # O PyInstaller esconde as imagens nesta pasta temporária
        base_dir = sys._MEIPASS 
    else:
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return os.path.join(base_dir, "assets", filename)

# --- ESTILO DARK PROFISSIONAL (QSS) ---
ESTILO_DARK = """
QMainWindow, QWidget {
    background-color: #1e1e1e;
    color: #e0e0e0;
    font-family: 'Segoe UI', Arial, sans-serif;
}
QTabWidget::pane {
    border: 1px solid #333333;
    background-color: #252526;
    border-radius: 5px;
}
QTabBar::tab {
    background-color: #2d2d30;
    color: #a0a0a0;
    padding: 10px 20px;
    border-top-left-radius: 4px;
    border-top-right-radius: 4px;
    margin-right: 2px;
}
QTabBar::tab:selected {
    background-color: #252526;
    color: #ffffff;
    border-bottom: 2px solid #27ae60;
}
QTabBar::tab:hover:!selected { background-color: #3e3e42; }
QLineEdit, QComboBox, QTextEdit {
    background-color: #2d2d30;
    border: 1px solid #3f3f46;
    border-radius: 4px;
    padding: 8px;
    color: #ffffff;
}
QLineEdit:focus, QComboBox:focus, QTextEdit:focus { border: 1px solid #007acc; }

#MenuLateral {
    background-color: #252526;
    border: 1px solid #333333;
    border-radius: 8px;
    outline: 0;
    padding: 10px 5px;
}
#MenuLateral::item {
    color: #cccccc;
    padding: 14px 15px;
    margin: 3px 5px;
    border-radius: 6px;
    font-size: 17px;
    font-weight: bold;
}
#MenuLateral::item:hover {
    background-color: #3e3e42;
    color: #ffffff;
}
#MenuLateral::item:selected {
    background-color: #007acc;
    color: #ffffff;
}
QPushButton {
    background-color: #3e3e42;
    border: 1px solid #555555;
    border-radius: 4px;
    padding: 8px 15px;
    color: #ffffff;
}
QPushButton:hover { background-color: #4e4e52; border: 1px solid #007acc; }
QPushButton:pressed { background-color: #007acc; }
QCheckBox { color: #e0e0e0; font-weight: bold; }
QCheckBox::indicator { width: 18px; height: 18px; border-radius: 3px; border: 1px solid #3f3f46; background-color: #2d2d30; }

QTreeView::indicator, QListView::indicator {
    width: 14px;
    height: 14px;
    margin: 4px;
    border-radius: 3px;
    border: 1px solid #95a5a6;
    background-color: #2d2d30;
}
QTreeView::indicator:unchecked:hover, QListView::indicator:unchecked:hover {
    border: 1px solid #007acc;
}

QCheckBox::indicator:checked, QTreeView::indicator:checked, QListView::indicator:checked {
    background-color: #27ae60;
    border: 1px solid #27ae60;
    image: url({check_icon_path});
}

QHeaderView::section {
    background-color: #2d2d30;
    color: #e0e0e0;
    padding: 4px;
    border: 1px solid #3f3f46;
}
"""

class JanelaPrincipal(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Backup Fácil Professional")
        
        # ✅ APLICANDO O SEU ÍCONE!
        caminho_icone = get_asset_path("icons/icon.svg")
        if os.path.exists(caminho_icone):
            self.setWindowIcon(QIcon(caminho_icone))
            
        self.resize(1350, 750)
        
        # Centraliza a janela no meio da tela
        tela = QApplication.primaryScreen().availableGeometry()
        tamanho = self.geometry()
        self.move((tela.width() - tamanho.width()) // 2, (tela.height() - tamanho.height()) // 2)
        
        widget_central = QWidget()
        self.setCentralWidget(widget_central)
        layout_principal = QHBoxLayout(widget_central)
        
        self.menu_lateral = QListWidget()
        self.menu_lateral.setObjectName("MenuLateral")
        self.menu_lateral.setFixedWidth(240)
        
        self.area_central = QStackedWidget()
        
        self.aba_backup = AbaBackup()
        self.aba_restauracao = AbaRestauracao()
        self.aba_comparar = AbaComparar()
        self.aba_recuperacao = AbaRecuperacaoDados()
        self.aba_dashboard = AbaDashboard()
        self.aba_logs = AbaLogs()
        self.aba_agendamento = AbaAgendamento()
        self.aba_duplicados = AbaDuplicados()
        self.aba_exclusao_segura = AbaExclusaoSegura()
        self.aba_verificar_hash = AbaVerificarHash()
        self.aba_sobre = AbaSobre()

        # ✅ CONEXÃO MÁGICA: Ligando o sinal de logs da Aba Backup para a Aba Logs
        self.aba_backup.novo_log.connect(self.aba_logs.adicionar_log)
        self.aba_restauracao.novo_log.connect(self.aba_logs.adicionar_log)
        self.aba_recuperacao.novo_log.connect(self.aba_logs.adicionar_log)
        self.aba_exclusao_segura.novo_log.connect(self.aba_logs.adicionar_log)

        # Adiciona no StackedWidget
        self.area_central.addWidget(self.aba_backup)
        self.area_central.addWidget(self.aba_restauracao)
        self.area_central.addWidget(self.aba_comparar)
        self.area_central.addWidget(self.aba_recuperacao)
        self.area_central.addWidget(self.aba_duplicados)
        self.area_central.addWidget(self.aba_exclusao_segura)
        self.area_central.addWidget(self.aba_verificar_hash)
        self.area_central.addWidget(self.aba_dashboard)
        self.area_central.addWidget(self.aba_logs)
        self.area_central.addWidget(self.aba_agendamento)
        self.area_central.addWidget(self.aba_sobre)

        # Adiciona os Itens no Menu Lateral
        self.menu_lateral.addItem("💾 Backup")
        self.menu_lateral.addItem("🕒 Restauração")
        self.menu_lateral.addItem("⚖️ Comparar")
        self.menu_lateral.addItem("🕵️ Recuperação Forense")
        self.menu_lateral.addItem("🗑️ Remover Duplicados")
        self.menu_lateral.addItem("☢️ Exclusão Segura")
        self.menu_lateral.addItem("🔐 Verificar Hash")
        self.menu_lateral.addItem("📈 Dashboard")
        self.menu_lateral.addItem("📝 Logs")
        self.menu_lateral.addItem("📅 Agendamento")
        self.menu_lateral.addItem("ℹ️ Sobre")

        # Conecta o clique no menu para mudar a tela
        self.menu_lateral.currentRowChanged.connect(self.area_central.setCurrentIndex)
        self.menu_lateral.setCurrentRow(0) # Inicia na primeira aba

        layout_principal.addWidget(self.menu_lateral)
        layout_principal.addWidget(self.area_central)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    check_icon_path = get_asset_path("icons/check.svg").replace('\\', '/')
    app.setStyleSheet(ESTILO_DARK.replace("{check_icon_path}", check_icon_path))
    
    # Adiciona o ícone também na barra de tarefas do sistema operacional
    caminho_icone = get_asset_path("icons/icon.svg")
    if os.path.exists(caminho_icone):
        app.setWindowIcon(QIcon(caminho_icone))
        
    janela = JanelaPrincipal()
    janela.show()
    
    sys.exit(app.exec())