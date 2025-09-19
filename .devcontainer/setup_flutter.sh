
#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y git xz-utils unzip curl ca-certificates libgl1
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
fi
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> $HOME/.bashrc
export PATH="$HOME/flutter/bin:$PATH"
flutter --version
flutter config --no-analytics || true
flutter doctor -v || true
flutter precache --android || true
