# Demo Script

Use this sequence when walking through Tasker in an interview.

1. Open the boards page and create a new board.
2. Point out that board creation inserts the board, owner membership, default lists, and activity event in a single `Ecto.Multi`.
3. Open the board in two browser windows and create a card in one window.
4. Show the other window receiving the update through PubSub.
5. Drag a card between lists and point to the transactional ordering logic in `Tasker.Boards.move_card/4`.
6. Mark a card done and show the activity panel.
7. Open the tests and explain why the card movement behavior is covered directly.

The strongest code paths to discuss are:

- `Tasker.Boards.create_board/2`
- `Tasker.Boards.move_card/4`
- `TaskerWeb.BoardLive.Show`
- `TaskerWeb.Presence`
