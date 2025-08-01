# Claude EPC Workflow

Engineering agents for Claude Code to deliver Senioer-level JavaScript and React solutions with minimal token usage.

## What is EPC?

EPC (Explore → Plan → Code) is a structured workflow using two specialized agents:
- **js-specialist**: JavaScript/TypeScript algorithms, performance, and architecture
- **react-virtuoso**: React components, state management, and UI optimization

## Key Features

- 🚀 **Senior expertise** without the verbosity
- 💡 **Concise by default** to preserve your token limits
- 📁 **Direct file writes** - no code in console output
- 🏗️ **Multiple modes**: standard, quick, or architect
- 🔧 **JavaScript default** with TypeScript option

## Installation

1. Clone this repository
2. Copy the agent files to your Claude Code agents directory
3. Copy the command file to your Claude Code commands directory

## Usage

```bash
# Standard workflow (Explore → Plan → Code)
Follow EPC to optimize user search with 50k records

# Quick mode (skip to implementation)
Follow EPC quick to add infinite scroll

# Architect mode (structural decisions only)
Follow EPC architect to refactor monolithic component

# TypeScript mode
Follow EPC typescript to build type-safe event system
```

## Exmaple Output

1. Explore: O(n) search, memory leak, 3s blocking
2. Plan: Map lookup, WeakMap cache, Web Worker
3. Code: userSearch.js, searchWorker.js, 3s→50ms

## Philosophy

Real engineering is about solving production problems with elegant, performant code. 
These agents understand legacy constraints, performance budgets, and incremental refactoring - not just greenfield ideals.
