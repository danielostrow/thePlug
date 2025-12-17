#!/usr/bin/env bash
#
# update-readme.sh - Dynamically updates the plugin table in README.md
#
# This script scans all plugin directories, extracts metadata from plugin.json,
# and regenerates the plugin table in the main README.md
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
README_FILE="$ROOT_DIR/README.md"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: brew install jq"
    exit 1
fi

# Build the plugin table
build_plugin_table() {
    echo "| Plugin | Version | Description | Last Updated |"
    echo "|--------|---------|-------------|--------------|"

    # Find all plugin.json files (excluding node_modules and hidden dirs except .claude-plugin)
    while IFS= read -r plugin_json; do
        # Get plugin directory (parent of .claude-plugin)
        plugin_dir=$(dirname "$(dirname "$plugin_json")")
        plugin_name=$(basename "$plugin_dir")

        # Skip if it's the root directory
        if [ "$plugin_dir" = "$ROOT_DIR" ]; then
            continue
        fi

        # Extract metadata from plugin.json
        version=$(jq -r '.version // "0.0.0"' "$plugin_json")
        description=$(jq -r '.description // "No description"' "$plugin_json")

        # Truncate description if too long
        if [ ${#description} -gt 120 ]; then
            description="${description:0:117}..."
        fi

        # Get last update date from git
        last_update=$(git -C "$ROOT_DIR" log -1 --format="%cs" -- "$plugin_dir" 2>/dev/null || echo "Unknown")

        echo "| [$plugin_name](./$plugin_name) | $version | $description | $last_update |"
    done < <(find "$ROOT_DIR" -path "*/.claude-plugin/plugin.json" -type f | sort)
}

# Generate categories section
build_categories() {
    declare -A categories

    while IFS= read -r plugin_json; do
        plugin_dir=$(dirname "$(dirname "$plugin_json")")
        if [ "$plugin_dir" = "$ROOT_DIR" ]; then
            continue
        fi

        category=$(jq -r '.category // "uncategorized"' "$plugin_json")
        plugin_name=$(basename "$plugin_dir")

        if [ -z "${categories[$category]}" ]; then
            categories[$category]="$plugin_name"
        else
            categories[$category]="${categories[$category]}, $plugin_name"
        fi
    done < <(find "$ROOT_DIR" -path "*/.claude-plugin/plugin.json" -type f)

    for category in "${!categories[@]}"; do
        echo "- **$category** - ${categories[$category]}"
    done | sort
}

# Build contributors section from marketplace.json
build_contributors() {
    local marketplace_json="$ROOT_DIR/.claude-plugin/marketplace.json"

    if [ ! -f "$marketplace_json" ]; then
        echo "<!-- No marketplace.json found -->"
        return
    fi

    echo '<table>'
    echo '<tr>'

    # Use jq to group plugins by author and generate contributor entries
    jq -r '
        .plugins
        | group_by(.author.name)
        | .[]
        | {
            author: .[0].author.name,
            plugins: [.[].name] | join(", "),
            github: (
              (.[0].repository // "" | capture("github\\.com/(?<user>[^/]+)").user)
              // (.[0].author.name | gsub(" "; "") | ascii_downcase)
            )
          }
        | "<td align=\"center\">\n<a href=\"https://github.com/\(.github)\" title=\"Plugins: \(.plugins)\">\n<img src=\"https://github.com/\(.github).png\" width=\"100px;\" alt=\"\(.author)\" style=\"border-radius:50%\"/>\n<br />\n<sub><b>\(.author)</b></sub>\n</a>\n<br />\n<sub>\(.plugins)</sub>\n</td>"
    ' "$marketplace_json"

    echo '<!-- Add more contributors here -->'
    echo '</tr>'
    echo '</table>'
}

# Update README.md between markers
update_readme() {
    local temp_file=$(mktemp)
    local in_plugins_section=false
    local in_contributors_section=false
    local table_content
    local contributors_content

    table_content=$(build_plugin_table)
    contributors_content=$(build_contributors)

    while IFS= read -r line; do
        if [[ "$line" == "<!-- PLUGINS-START -->" ]]; then
            echo "$line" >> "$temp_file"
            echo "$table_content" >> "$temp_file"
            in_plugins_section=true
        elif [[ "$line" == "<!-- PLUGINS-END -->" ]]; then
            echo "$line" >> "$temp_file"
            in_plugins_section=false
        elif [[ "$line" == "<!-- CONTRIBUTORS-START -->" ]]; then
            echo "$line" >> "$temp_file"
            echo "$contributors_content" >> "$temp_file"
            in_contributors_section=true
        elif [[ "$line" == "<!-- CONTRIBUTORS-END -->" ]]; then
            echo "$line" >> "$temp_file"
            in_contributors_section=false
        elif [ "$in_plugins_section" = false ] && [ "$in_contributors_section" = false ]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$README_FILE"

    mv "$temp_file" "$README_FILE"
}

echo "Scanning for plugins..."
plugin_count=$(find "$ROOT_DIR" -path "*/.claude-plugin/plugin.json" -type f | wc -l | tr -d ' ')
echo "Found $plugin_count plugin(s)"

echo "Updating README.md..."
update_readme

echo "Done! README.md has been updated."
