// id is the transcript row's uuid, which is also the UserMessage requestId
// isReply marks a block of Claude's reply; absent on a typed prompt
export type Item = { id: string; text: string; isReply?: boolean }

declare module 'claude-code' {
  interface PluginState {
    'talk-stack': {
      items: Shaped<Item[]>
      last: Item | null
      cursor: number
    }
  }
}
