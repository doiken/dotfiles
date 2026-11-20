// id is the transcript row's uuid, which is also the UserMessage requestId
// isReply marks a block of Claude's reply; absent on a typed prompt.
// text is one line (a memo, a toast); body is the row as written, for the pane
// (absent on items pinned before the pane existed)
export type Item = { id: string; text: string; isReply?: boolean; body?: string }

declare module 'claude-code' {
  interface PluginState {
    'chat-pins': {
      items: Shaped<Item[]>
      last: Item | null
      // ids of the pane's entries unfolded to their full text, this session only
      unfolded: string[]
    }
  }
}
