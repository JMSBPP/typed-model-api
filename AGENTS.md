# INSTRUCTIONS

`session_id` dynamically changes per worktree.

## [<for any worktree>::specifier](session_id=0edfd256-a4aa-4944-9b0f-e267a6def872)

As the specifier we have a git visible `.spec/` where we write the specification.

## [<for any worktree>::implementer](session_id=18a9b5ed-b6bd-4f7f-8b32-60b7b65114f8)

Once implementation is completed, ask the user to run `/grill-me` to design the CI gate that gates the PR from this worktree into `dev`. Once that design is completed, add the gate and make sure every PR that requests merge into `dev` always runs that CI.
