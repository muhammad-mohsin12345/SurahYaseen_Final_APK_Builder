@echo off
REM 1) GitHub par khali repo banayen (README ke baghair)  2) Neeche URL apni repo ka likhen  3) Is file par double-click karein
set REPO_URL=https://github.com/YOUR_USERNAME/surahyaseen.git
git init
git add .
git commit -m "Surah Yaseen app"
git branch -M main
git remote add origin %REPO_URL%
git push -u origin main
pause
