#!/bin/bash
VAULT="/Users/yashchitneni/Library/Mobile Documents/iCloud~md~obsidian/Documents/obi-vault"
REPO="$HOME/Development/active/personal/slides-site"
CHANGED=false

find "$VAULT/1-Projects" -path "*/slides/*.html" -type f 2>/dev/null | while read src; do
  project=$(echo "$src" | sed "s|$VAULT/1-Projects/||" | cut -d'/' -f1)
  filename=$(basename "$src")
  slug=$(echo "$project" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  dest_dir="$REPO/$slug"
  mkdir -p "$dest_dir"
  if ! cmp -s "$src" "$dest_dir/$filename" 2>/dev/null; then
    cp "$src" "$dest_dir/$filename"
    echo "Updated: $slug/$filename"
    CHANGED=true
  fi
done

# Also copy any images/assets from slides dirs
find "$VAULT/1-Projects" -path "*/slides/*" -not -name "*.html" -type f 2>/dev/null | while read src; do
  project=$(echo "$src" | sed "s|$VAULT/1-Projects/||" | cut -d'/' -f1)
  filename=$(basename "$src")
  slug=$(echo "$project" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  dest_dir="$REPO/$slug"
  mkdir -p "$dest_dir"
  if ! cmp -s "$src" "$dest_dir/$filename" 2>/dev/null; then
    cp "$src" "$dest_dir/$filename"
    echo "Updated asset: $slug/$filename"
  fi
done

# Generate index page
cat > "$REPO/index.html" << 'INDEXEOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Slides</title>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: -apple-system, BlinkMacSystemFont, 'SF Pro', sans-serif; background: #0a0a0a; color: #e0e0e0; padding: 2rem; min-height: 100vh; }
h1 { font-size: 1.5rem; font-weight: 600; margin-bottom: 2rem; color: #fff; }
.project { margin-bottom: 2rem; }
.project-name { font-size: 1.1rem; font-weight: 500; color: #888; margin-bottom: 0.5rem; text-transform: uppercase; letter-spacing: 0.05em; font-size: 0.85rem; }
.slides { display: flex; flex-direction: column; gap: 0.5rem; }
a { color: #60a5fa; text-decoration: none; padding: 0.5rem 0; display: block; }
a:hover { color: #93c5fd; }
</style>
</head>
<body>
<h1>Slides</h1>
<div id="content"></div>
<script>
INDEXEOF

# Build the index dynamically from what's in the repo
echo "const slides = {" >> "$REPO/index.html"
for dir in "$REPO"/*/; do
  [ -d "$dir" ] || continue
  dirname=$(basename "$dir")
  [ "$dirname" = ".git" ] && continue
  display=$(echo "$dirname" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
  echo "  \"$display\": [" >> "$REPO/index.html"
  for f in "$dir"*.html; do
    [ -f "$f" ] || continue
    fname=$(basename "$f")
    label=$(echo "$fname" | sed 's/\.html$//' | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    echo "    { url: \"$dirname/$fname\", title: \"$label\" }," >> "$REPO/index.html"
  done
  echo "  ]," >> "$REPO/index.html"
done

cat >> "$REPO/index.html" << 'INDEXEOF2'
};
const content = document.getElementById('content');
Object.entries(slides).forEach(([project, decks]) => {
  if (decks.length === 0) return;
  const div = document.createElement('div');
  div.className = 'project';
  div.innerHTML = `<div class="project-name">${project}</div><div class="slides">${decks.map(d => `<a href="${d.url}">${d.title}</a>`).join('')}</div>`;
  content.appendChild(div);
});
</script>
</body>
</html>
INDEXEOF2

cd "$REPO"
git add -A
if ! git diff --cached --quiet 2>/dev/null; then
  git commit -m "Sync slides $(date +%Y-%m-%d\ %H:%M)"
  git push origin main 2>/dev/null || true
  echo "Pushed changes"
else
  echo "No changes to sync"
fi
