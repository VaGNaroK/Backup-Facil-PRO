import sys
import os
from PySide6.QtWidgets import QApplication, QListWidget, QListWidgetItem
from PySide6.QtCore import Qt

app = QApplication(sys.argv)
check_icon_path = os.path.abspath("assets/icons/check.svg").replace('\\', '/')

app.setStyleSheet(f"""
QListView {{
    background-color: #1e1e1e;
    color: #00ff00;
}}
QListView::indicator {{ 
    width: 14px; 
    height: 14px; 
    margin: 4px;
    border-radius: 3px; 
    border: 1px solid #95a5a6; 
    background-color: #2d2d30; 
}}
QListView::indicator:checked {{
    background-color: #27ae60; 
    border: 1px solid #27ae60;
    image: url({check_icon_path});
}}
""")

w = QListWidget()
w.setFixedSize(200, 100)
item = QListWidgetItem("Test Item Checked")
item.setFlags(item.flags() | Qt.ItemIsUserCheckable)
item.setCheckState(Qt.Checked)
w.addItem(item)

item2 = QListWidgetItem("Test Item Unchecked")
item2.setFlags(item2.flags() | Qt.ItemIsUserCheckable)
item2.setCheckState(Qt.Unchecked)
w.addItem(item2)

w.show()

img = w.grab()
img.save("test_out.png")
print("Saved to test_out.png")
