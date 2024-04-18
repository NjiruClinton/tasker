# Architecture Notes

Tasker follows the usual Phoenix shape: business rules live in contexts, LiveViews own UI state, and the database protects important relationships.

## Boundaries

- `Tasker.Accounts` owns lightweight user records used for board ownership, memberships, and activity history.
- `Tasker.Boards` owns board workflows, including default list creation, card creation, card updates, card movement, and real-time broadcasts.
- `TaskerWeb.BoardLive.Index` handles board discovery and creation.
- `TaskerWeb.BoardLive.Show` handles the collaborative board workspace.

## Real-Time Flow

Board mutations happen through the `Tasker.Boards` context. After a successful transaction, the context broadcasts an event on the board topic with Phoenix PubSub. Connected LiveViews subscribe to that topic and reload the board state. This keeps browser sessions consistent without pushing database details into the UI.

Presence uses a separate `boards:<id>:presence` topic so collaborator awareness can change independently from board content.

## Card Ordering

Card movement is transactional. The moved card is inserted into the requested list position, then every card in the source and target lists is normalized to a zero-based position. This prevents duplicate positions and keeps ordering deterministic for future queries.

## Trade-Offs

The repository keeps authentication intentionally simple so the portfolio surface stays focused on Phoenix, LiveView, Ecto, and real-time collaboration. The schema is ready for full auth later because boards already have owners, memberships, roles, assignees, and activity actors.
