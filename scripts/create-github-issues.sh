#!/bin/bash

if ! command -v gh &> /dev/null; then
  echo "GitHub CLI (gh) is not installed. Please install it first: brew install gh"
  exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

echo "🚀 מתחיל ביצירת התוויות (Labels)..."

ensure_label() {
  local name="$1"
  local color="$2"
  gh label create "$name" --color "$color" --force 2>/dev/null
  echo "  ✓ $name"
}

ensure_label config          1d76db
ensure_label ci-cd           006b75
ensure_label marketing       fbca04
ensure_label documentation   0075ca
ensure_label qa              d93f0b
ensure_label enhancement     a2eeef

echo "✅ תוויות נוצרו/עודכנו."
echo "📝 מתחיל ביצירת המשימות עבור Orkestra HA Add-on..."

create_issue() {
  local title="$1"
  local labels="$2"
  local body="$3"

  echo "יוצר משימה: $title"
  gh issue create --title "$title" --label "$labels" --body "$body"
}

# ==========================================
# CONFIGURATION SYNC
# ==========================================

create_issue \
  "[Add-on] ניהול תצורות (Configuration Sync)" \
  "config,ci-cd,enhancement" \
  "## Context
במסמך הארכיטקטורה מצוין שקיים נתק חלקי (Config drift) בין \`config.yaml\` שיושב ב-\`orkestra-core\` לבין זה שיושב כאן. זה עלול למנוע ממשתמשים להזין את פרטי הענן שלהם.

## Tasks
- [ ] **סנכרון סכמת האפשרויות:** העתקת שדות \`orkestra_cloud_url\` ו-\`orkestra_instance_token\` למסמך \`orkestra/config.yaml\` כאן כדי שיופיעו במסך ההגדרות של התוסף.
- [ ] **אוטומציה לסנכרון (CI/CD):** עדכון ה-Workflow של \`build-addon.yaml\` (במאגר ה-Core) כך שבזמן עדכון גרסה, הוא יעתיק את כל קובץ ה-\`config.yaml\` ל-\`orkestra-ha-addon\`, ולא יעדכן רק את מספר הגרסה."

# ==========================================
# MARKETING & INSTALLATION
# ==========================================

create_issue \
  "[Add-on] שיווק פנימי והוראות התקנה" \
  "marketing,documentation,enhancement" \
  "## Context
זה מה שהמשתמשים רואים בתוך ה-Add-on Store לפני שהם לוחצים על התקנה.

## Tasks
- [ ] **כתיבת README.md שיווקי בתוך התוסף:** להוסיף קובץ שיוצג בתוך ה-UI של Home Assistant, שיסביר במשפט מה זה Orkestra ומה היתרונות (AI, עיצוב מודרני, אוטומציות).
- [ ] **עדכון תמונות הלוגו והאייקון:** לוודא שהתמונות (\`icon.png\`, \`logo.jpeg\`) איכותיות (רזולוציה מתאימה) ומעבירות את המיתוג העדכני של המוצר (עיצוב זכוכית, מינימליסטי)."

# ==========================================
# QA
# ==========================================

create_issue \
  "[Add-on] אבטחת איכות והתקנה (QA)" \
  "qa,enhancement" \
  "## Context
שיפור יציבות ההתקנה ומניעת שגיאות תאימות ארכיטקטורה.

## Tasks
- [ ] **תיעוד Watchdog:** הוספת הגדרת \`watchdog: default\` ל-\`config.yaml\` כדי ש-Supervisor יאתחל את התוסף אוטומטית אם ה-Express קורס.
- [ ] **בדיקות תאימות ארכיטקטורה (Arch Check):** לוודא שמצד אחד ה-\`config.yaml\` לא מצהיר על \`armhf\` (מעבדים ישנים מאוד) אם ה-GitHub Actions של ה-Core לא באמת בונה להם אימג'. פער כזה יגרום לשגיאת התקנה אצל משתמשי Raspberry Pi ישנים."

echo "🎉 כל המשימות עבור Orkestra HA Add-on נוצרו בהצלחה!"
