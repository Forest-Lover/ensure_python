#### 项目说明
通过预定义config.bat和config.sh。在执行对应平台的脚本前，自动配置python环境
可以指定：
* python版本
* requirements.txt的文件列表

#### 使用方式
1. 拷贝ensure_python目录到对应工程
2. 修改config.bat和config.sh中对应变量配置：
    * PYTHON_VERSION：需要的python版本
    * REQUIREMENTS_LIST：requirements.txt的文件路径列表（相对于config文件）

#### TODO
* python-install脚本自己实现下，如果对应python没有安装需要先安装
* (linux还没开始写)