#!/bin/bash

# Function to generate index.html for a directory
generate_index() {
  local dir="$1"
  local parent_dir="$(dirname "$dir")"
  local relative_parent=".."

  if [ "$dir" == "./public" ]; then
    return
  fi

  # Get current directory name (relative to root)
  local current_path="${dir#.\/public/}"
  current_path="/${current_path:-/}"

  # Start HTML
  cat >"$dir/index.html" <<HTML
<!DOCTYPE html>
<html>
<head>
    <title>Index of $current_path</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,100..700;1,100..700&display=swap" rel="stylesheet">
    <style>
        body { font-family: "Roboto Mono", monospace; font-optical-sizing: auto; margin: 20px; color: #c5cae9; background-color: #363457; }
        a { color: #f1c40f; }
        a:hover { color: #fde68a; }
        h1 { font-size: 1.5em; }
        table { border-collapse: collapse; width: 100%; }
        th, td { text-align: left; padding: 8px; border-bottom: 1px solid rgba(0, 0, 0, 0.5) }
        th { background-color: rgba(0, 0, 0, 0.2) }
        address { opacity: 0.75; font-size: .8em; }
    </style>
</head>
<body>
    <h1>Index of $current_path</h1>
    <table>
        <tr>
            <th>Name</th>
            <th>Last Modified</th>
            <th>Size</th>
        </tr>
HTML

  # Add parent directory link (if not root)
  if [ "$dir" != "." ]; then
    echo "        <tr><td><a href=\"$relative_parent/\">../</a></td><td>-</td><td>-</td></tr>" >>"$dir/index.html"
  fi

  # List directories first
  find "$dir" -maxdepth 1 -type d ! -path "$dir" | sort | while read -r subdir; do
    local subdir_name="$(basename "$subdir")"
    local mod_time="$(stat -c "%y" "$subdir" | cut -d ' ' -f 1)"
    echo "        <tr><td><a href=\"$subdir_name/\">$subdir_name/</a></td><td>$mod_time</td><td>-</td></tr>" >>"$dir/index.html"
  done

  # List files
  find "$dir" -maxdepth 1 -type f ! -name "index.html" | sort | while read -r file; do
    local file_name="$(basename "$file")"
    local mod_time="$(stat -c "%y" "$file" | cut -d ' ' -f 1)"
    local file_size="$(stat -c "%s" "$file" | numfmt --to=iec)"
    echo "        <tr><td><a href=\"$file_name\">$file_name</a></td><td>$mod_time</td><td>$file_size</td></tr>" >>"$dir/index.html"
  done

  # Close HTML
  cat >>"$dir/index.html" <<HTML
    </table>
    <br>
    <address>— by <a href="/">https://pkg.afonso.dev</a></address>
</body>
</html>
HTML

  echo "Generated index.html for: $dir"
}

# Main: Recursively process directories
find ./public -type d | while read -r dir; do
  generate_index "$dir"
done

echo "Done!"
