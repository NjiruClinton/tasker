# Tasker

Tasker is a collaborative Kanban board built with Phoenix, LiveView, Ecto, PostgreSQL, and Phoenix Presence.

The app is designed as a focused portfolio project for Elixir roles: it shows a practical domain model, transactional card movement, real-time board updates, and a LiveView-first interface without a separate frontend framework.

## Highlights

- Real-time board updates through Phoenix PubSub.
- Lightweight collaborator awareness with Phoenix Presence.
- Boards with members, roles, lists, cards, priorities, labels, due dates, and activity history.
- Transactional card moves that preserve per-list ordering.
- Focused tests around the highest-risk Kanban behavior.

## Getting Started

```sh
mix setup
mix phx.server
```

Then open `http://localhost:4000`.

## Useful Commands

```sh
mix test
mix ecto.reset
mix assets.build
```

## Project Notes

Tasker intentionally keeps authentication simple and uses a demo collaborator in development. That keeps the repository centered on the Phoenix and LiveView work that matters for a portfolio review: contexts, schemas, database constraints, real-time eventing, and user-facing workflows.
