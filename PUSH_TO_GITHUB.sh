#!/bin/bash
# 1) GitHub par khali repo banayen  2) URL badlen  3) bash PUSH_TO_GITHUB.sh
REPO_URL="https://github.com/YOUR_USERNAME/surahyaseen.git"
git init && git add . && git commit -m "Surah Yaseen app" && git branch -M main \
 && git remote add origin "$REPO_URL" && git push -u origin main
