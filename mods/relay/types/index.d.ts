export type RelayTask = {
  id: string
  title: string
  mode: string
  state: 'running' | 'done' | 'blocked'
  ageMin: number
}

export type RelayChat = {
  title: string
  folder: string
  done: number
  total: number
  current: string
  ageMin: number
  isMe: boolean
}

declare module 'claude-code' {
  interface PluginState {
    relay: { tasks: RelayTask[]; chats: RelayChat[] }
  }
}
