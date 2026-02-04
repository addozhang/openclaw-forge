# OpenClaw Forge 🛠️

A collection of skills and agents that empower AI assistants with practical capabilities.

[中文文档](README_zh.md)

## Skills

Specialized modules that provide specific functionalities:

- **google-tasks** - Google Tasks management (OAuth authentication, CRUD operations)
- **mcp-builder** - Guide for building MCP (Model Context Protocol) servers
- **ralph-loop** - Generate AI agent loop scripts (supports Codex, Claude Code, Goose, etc.)
- **research-prep** - Research material collection and organization workflow for technical writing
- **system-status** - System health monitoring (CPU, memory, disk, processes, network)
- **task-status** - Long-running task status update helper (periodic reporting, templated messages)

## Agents

Autonomous intelligent agents:

- **daily-briefing** - Daily briefing generator (email, calendar, task summary)
- **obsidian-organizer** - Obsidian note organizer (auto-categorization, link completion)

## Usage

Each skill and agent directory contains detailed documentation in `SKILL.md` or `AGENT.md`.

## Structure

```
openclaw-forge/
├── skills/           # Skill modules
│   └── [skill-name]/
│       ├── SKILL.md
│       └── scripts/
└── agents/           # Intelligent agents
    └── [agent-name]/
        └── AGENT.md
```

## Contributing

New skills and agents are welcome! Please ensure complete documentation and examples are included.

## License

MIT
