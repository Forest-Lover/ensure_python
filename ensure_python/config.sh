#!/bin/bash

ORIGINAL_DIR=$(pwd)
cd "$(dirname "${BASH_SOURCE[0]}")"

PYTHON_VERSION="3.7"
REQUIREMENTS_LIST=(
    "../examples/requirements.txt"
)

PYTHON_INSTALLER=python-installer.sh
VENV_DIR=".python-venv-linux"
CHECKSUM_FILE="$VENV_DIR/requirements.md5"

check_python_version() {
    python_exe="$1"
    if [ -z "$python_exe" ]; then
        python_exe="python3"
    fi
    version_str=$($python_exe --version 2>&1)
    if [[ $version_str == *"Python $PYTHON_VERSION"* ]]; then
        return 0
    else
        return 1
    fi
}

ensure_python_venv() {
    mkdir -p $VENV_DIR
    # linux python3不一定有venv的环境，这里只确保requirements.txt都正确安装就行
}

ensure_requirements() {
    REINSTALL_REQUIREMENTS=false
    for R in "${REQUIREMENTS_LIST[@]}"; do
        if [ -f "$R" ]; then
            CURRENT_CHECKSUM=$(md5sum "$R" | cut -d ' ' -f 1)
            STORED_CHECKSUM=""
            if [ -f "$CHECKSUM_FILE" ]; then
                STORED_CHECKSUM=$(grep "$R" "$CHECKSUM_FILE" | cut -d ' ' -f 2)
            fi
            # echo $CURRENT_CHECKSUM,$STORED_CHECKSUM
            if [ "$CURRENT_CHECKSUM" != "$STORED_CHECKSUM" ]; then
                REINSTALL_REQUIREMENTS=true
            fi
        fi
    done
    if [ "$REINSTALL_REQUIREMENTS" = true ]; then
        echo "Changes detected in requirements files. Reinstalling dependencies..."
        python3 -m pip install --upgrade pip
        rm -f "$CHECKSUM_FILE"
        for R in "${REQUIREMENTS_LIST[@]}"; do
            if [ -f "$R" ]; then
                pip3 install -r "$R"
                if [ $? -eq 0 ]; then
                    MD5SUM=$(md5sum "$R" | cut -d ' ' -f 1)
                    echo "$R $MD5SUM" >> "$CHECKSUM_FILE"
                else
                    echo "error when pip install file:$R"
                    return 1
                fi
            fi
        done
    fi
}

main() {
    check_python_version
    if [ $? -ne 0 ]; then
        FOUND_PATH=""
        IFS=: read -ra PATHS <<< "$(which -a python3)"
        for p in "${PATHS[@]}"; do
            check_python_version "$p"
            if [ $? -eq 0 ]; then
                FOUND_PATH="$p"
                PYTHON_DIR=$(dirname "$p")
                export PATH="$PYTHON_DIR:$PATH"
                echo "Updated PATH with Python at $PYTHON_DIR"
                break
            fi
        done
        if [ -z "$FOUND_PATH" ]; then
            echo "Python $PYTHON_VERSION is not installed."
            echo "Continue to open install Program"
            read -p "Press any key to continue... " -n1 -s
            bash "$PYTHON_INSTALLER"
            return 0
        fi
    fi

    check_python_version
    if [ $? -ne 0 ]; then
        echo The correct version of Python is not installed
        return 1
    fi

    ensure_python_venv
    if [ $? -ne 0 ]; then
        return 1
    fi

    ensure_requirements
    if [ $? -ne 0 ]; then
        return 1
    fi
}
main; mainRet=$?

cd "$ORIGINAL_DIR" #一般用source调用该脚本，所以需要设置到原目录

return $mainRet