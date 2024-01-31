import sys
from PyQt5.QtWidgets import QApplication, QWidget, QLabel, QVBoxLayout, QDesktopWidget
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont

# 创建一个应用(Application)实例
app = QApplication(sys.argv)

# 创建一个窗口(Widget)实例
window = QWidget()

# 设置窗口标题
window.setWindowTitle('Hello')

# 创建一个垂直布局管理器
layout = QVBoxLayout()

# 创建一个标签(Label)实例并设置其文本
label = QLabel('Hello, World!')
label.setAlignment(Qt.AlignCenter)  # 设置标签文本居中对齐

# 设置字体为加粗和字号大小
font = QFont()
font.setBold(True)
font.setPointSize(14)
label.setFont(font)

# 将标签添加到布局管理器
layout.addWidget(label)

# 将布局应用到窗口
window.setLayout(layout)

# 设置窗口大小
window.resize(400, 300)

# 获取屏幕尺寸和窗口尺寸
screen = QDesktopWidget().screenGeometry()
size = window.geometry()

# 计算窗口居中的x和y坐标
x = (screen.width() - size.width()) / 2
y = (screen.height() - size.height()) / 2

# 设置窗口位置
window.move(int(x), int(y))

# 显示窗口
window.show()

# 运行应用的事件循环
sys.exit(app.exec_())