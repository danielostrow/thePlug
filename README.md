# thePlug Marketplace

A curated collection of Claude Code plugins for enhanced AI-assisted development workflows.

## Installation

Install any plugin directly from this marketplace:

```bash
claude plugins install /path/to/ClaudePlugins/<plugin-name>
```

Or clone the entire marketplace:

```bash
git clone https://github.com/danielostrow/theplug-marketplace.git
cd theplug-marketplace
claude plugins install ./<plugin-name>
```

## Available Plugins

<!-- PLUGINS-START -->
| Plugin | Version | Description | Last Updated |
|--------|---------|-------------|--------------|
| [scrape-studio](./scrape-studio) | 1.0.0 | Visual AI-powered web scraper creation with dynamic Puppeteer scripts, captcha handling, scheduling, and ETL pipeline... | 2025-12-17 |
<!-- PLUGINS-END -->

## Plugin Categories

- **data-extraction** - Tools for scraping, parsing, and extracting data from various sources

## Contributing

Want to add your plugin to thePlug marketplace?

1. Fork this repository
2. Add your plugin directory with a valid `.claude-plugin/plugin.json`
3. Run `./scripts/update-readme.sh` to update the plugin list
4. Submit a pull request

### Plugin Requirements

- Must include a `.claude-plugin/plugin.json` manifest
- Must include a `README.md` with usage documentation
- Should follow Claude Code plugin best practices

## Scripts

### Update Plugin List

Regenerate the plugin table in this README:

```bash
./scripts/update-readme.sh
```

## License

Each plugin maintains its own license. See individual plugin directories for details.

---

*Maintained by [Daniel Ostrow](https://neuralintellect.com)*
