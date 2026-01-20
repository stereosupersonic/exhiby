# Exhiby Documentation

## Overview

This directory contains implementation plans and feature documentation for the Exhiby project - a digital museum content management system for museum-wartenberg.de.

## Structure

```
docs/
├── README.md                           # This file
├── ROADMAP.md                          # High-level project roadmap
├── features/                           # Feature-specific documentation
│   ├── _template.md                    # Template for new features
│   ├── articles.md                     # Articles/Press reports feature
│   ├── assets.md                       # Asset management feature
│   ├── collections.md                  # Collections and albums feature
│   ├── artists.md                      # Artist profiles feature
│   ├── pages.md                        # Static pages feature
│   ├── guest-uploads.md                # Guest upload workflow feature
│   └── ai-tagging.md                   # AI-powered tagging feature
└── architecture/                       # Architecture decisions (future)
    └── ...
```

## How to Use

1. **New Feature Planning**: Copy `features/_template.md` to create a new feature file
2. **Requirements Gathering**: Document rough requirements in the appropriate feature file
3. **Implementation**: Use the feature file as input for Claude Code to generate detailed implementation plans
4. **Tracking**: Update status in ROADMAP.md as features progress

## Feature File Workflow

```
[Rough Requirements] → [Feature File] → [Claude Code] → [Implementation Plan] → [Code]
```

## Conventions

- Feature files use Markdown format
- Status indicators: 🔴 Not Started, 🟡 In Progress, 🟢 Completed
- Priority levels: P0 (Critical), P1 (High), P2 (Medium), P3 (Low)
