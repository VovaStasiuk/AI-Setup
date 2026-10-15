export type Meter = {
  tokens: number
  readUsd: number
  writeUsd: number
  sessionUsd: number | null
  limits: string
  lastActivity: number
}

export type PlanItem = { id: string; title: string; state: 'pending' | 'in_progress' | 'completed'; size: number }

export type Activity = { running: boolean; startedAt: number; steps: number; current: string; helpers: number }

export type ShipStep = { key: string; label: string; state: 'todo' | 'pass' | 'fail' | 'skip'; note: string }

declare module 'claude-code' {
  interface PluginState {
    cockpit: {
      meter: Meter | null
      plan: PlanItem[]
      planStart: number
      suggestions: string[]
      steps: ShipStep[] | null
      activity: Activity
      goal: string
    }
  }
}
