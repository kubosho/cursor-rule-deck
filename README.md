# Cursor rule deck

My curated of personal [Cursor Project Rules](https://docs.cursor.com/context/rules-for-ai#project-rules-recommended) deck.

## Overview

This repository contains my custom rules for Cursor, managed as Markdown files.

- All finalized rules are in `rules/`.
- Work-in-progress drafts are in `rules/drafts/`.
- Use the `setup.sh` to deploy rules into any target repository `.cursor/rules` directory.

## Setup

```bash
./setup.sh --target /path/to/your/project
```

### Setup options

```bash
# Can use positional argument
./setup.sh /path/to/your/project
# Can change the output directory with `--rules-dir` (default: .cursor/rules)
./setup.sh --target /path/to/your/project --rules-dir {your_custom_directory}
```

## Structure

```
.
├── LICENSE
├── README.md
└── rules/
    ├── 00_personality.md
    ├── 01_important.md
    ├ ...
    └── drafts/
```

## License

[MIT License](./LICENSE).
