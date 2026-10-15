import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Activity, Meter, PlanItem, ShipStep } from '../types'

const meter = atom({ plugin: 'cockpit', key: 'meter' } as const, null as Meter | null)
const plan = atom({ plugin: 'cockpit', key: 'plan' } as const, [] as PlanItem[])
const planStart = atom({ plugin: 'cockpit', key: 'planStart' } as const, 0)
const suggestions = atom({ plugin: 'cockpit', key: 'suggestions' } as const, [] as string[])
const steps = atom({ plugin: 'cockpit', key: 'steps' } as const, null as ShipStep[] | null)
const activity = atom({ plugin: 'cockpit', key: 'activity' } as const, { running: false, startedAt: 0, steps: 0, current: '', helpers: 0 } as Activity)
const goal = atom({ plugin: 'cockpit', key: 'goal' } as const, '')

const SIZES: Record<string, number> = { S: 1, M: 2, L: 3 }
const PROGRESS_SECTION = {
  id: 'cockpit:progress',
  scope: 'session',
  text: 'Progress tracking: for any request that takes more than a few steps, first write a short task list with TaskCreate (one task per meaningful step, metadata.size "S", "M" or "L" by effort), then mark each task in_progress when you start it and completed when it is done, adding tasks if you find more work. Skip the list for one-step answers.',
} as const
const GOAL_BRIEF = 'A /goal was set. Before doing the work, write the full task list with TaskCreate (each task sized with metadata.size "S", "M" or "L"), then keep it updated as you go so the progress bar stays accurate.'

// $ per million tokens: cache read, 1-hour cache write
const PRICES: [RegExp, number, number][] = [
  [/fable/, 0.25, 20],
  [/opus-5-5/, 0.2, 8],
  [/opus/, 0.5, 10],
  [/sonnet/, 0.2, 4],
  [/haiku/, 0.01, 0.2],
]
const NUDGES = [250_000, 400_000, 600_000]
const BIG_CHAT = 150_000
const CACHE_TTL_MS = 60 * 60_000
const WARN_MS = 5 * 60_000
const RESEND_WINDOW_MS = 3 * 60_000
const FROM_USER = new Set(['composer', 'bridge'])
const LIMIT_LABELS: Record<string, string> = { five_hour: '5h', seven_day: 'week' }

const HANDOFF = 'Use the handoff-protocol skill: write .ai/tasks/HANDOFF-<topic>.md for this chat and give me the one line to paste into a fresh chat.'

const NEXT_RULES = `From the assistant message below, list the concrete next actions the user could ask for right now (proposed options, a question's choices, or the obvious next step).
- At most 3, each an imperative instruction of at most 8 words that the user could send as-is (for example "Build the context meter first").
- If the message proposes nothing actionable, output only NONE.
Output one action per line, nothing else.`

const SHIP_STEPS: [string, string][] = [
  ['lint', 'lint'],
  ['build', 'build'],
  ['tests', 'tests'],
  ['review', 'review'],
  ['browser', 'browser'],
  ['commit', 'commit msg'],
  ['ticket', 'ticket note'],
]
const SHIP_TOOL = 'mcp__cockpit__ship_step'
const DONE_WORDS = /\b(done|complete[d]?|ready to (merge|commit|ship)|all (checks|steps) pass)\b/i
const SHIP_BRIEF = `The user ran /ship. Run the done-checklist for the current changes, in order. After each step call the ship_step tool (load it with ToolSearch if deferred) with step, state ("pass", "fail" or "skip") and a short note.
1. lint: run the project's linters on the changed files only (see CLAUDE.md/AGENTS.md). Pass only with zero findings in those files.
2. build: if frontend files changed, run the project's build or type check; otherwise skip with a note.
3. tests: run the tests that cover the changed code; never rebuild the test database.
4. review: run the project's reviewer agent if one exists , plus a Codex review if the codex plugin is available. Fix what is clearly right; list the rest.
5. browser: if the UI changed, check it in the browser by clicking through from the dashboard; otherwise skip with a note.
6. commit: draft a commit message in the repo's style, with no AI attribution. Do not commit.
7. ticket: draft a short comment for the ticket (Plane or Linear) saying what changed and how it was checked. Do not post it unless the user asks.
If a step fails, fix it and run it again before moving on, or mark it fail and say why. Finish with a plain summary: what passed, what failed or was skipped, the commit message, the ticket note. Never commit or push.`

function prices(model: string): [number, number] {
  const hit = PRICES.find(([re]) => re.test(model))
  return hit ? [hit[1], hit[2]] : [0.2, 8]
}

function k(n: number) {
  return `${Math.round(n / 1000)}k`
}

function usd(n: number) {
  return n < 0.1 ? `$${n.toFixed(3)}` : `$${n.toFixed(2)}`
}

function label(e: any): string {
  const file = (e.file_path ?? e.notebook_path ?? '').split('/').pop()
  if (e.tool === 'Bash') return `run ${String(e.command ?? '').replace(/\s+/g, ' ').slice(0, 40)}`
  if (file) return `${e.tool} ${file}`
  if (e.tool === 'Agent') return `helper: ${String(e.description ?? '').slice(0, 40)}`
  if (e.tool === 'Grep' || e.tool === 'Glob') return `search ${String(e.pattern ?? '').slice(0, 30)}`
  return String(e.tool).replace(/^mcp__([^_]+)__/, '$1 ')
}

function clockText(ms: number) {
  const s = Math.max(0, Math.round(ms / 1000))
  return s < 60 ? `${s}s` : `${Math.floor(s / 60)}m ${String(s % 60).padStart(2, '0')}s`
}

function bar(done: number, total: number, width = 16) {
  const n = total ? Math.round((done / total) * width) : 0
  return '█'.repeat(n) + '░'.repeat(width - n)
}

// A broken cockpit must never block a prompt or a tool
function failOpen($: any, e: any, next: any) {
  return next(e)
}

// Writes this chat's progress where relay's /tasks pane can list it
async function publishChat($: any, title: string) {
  const home = (await $.env.get('HOME')) || ''
  if (!home) return
  const dir = `${home}/.claude/mods-data/cockpit/chats`
  await $.process.run(['mkdir', '-p', dir], { timeoutMs: 5_000 })
  const items: PlanItem[] = await read($, plan)
  const root: string = await $.session.root()
  await $.fs.write(
    `${dir}/${await $.session.id()}.json`,
    JSON.stringify({
      title,
      folder: root.split('/').pop(),
      done: items.filter(i => i.state === 'completed').length,
      total: items.length,
      current: items.find(i => i.state === 'in_progress')?.title ?? '',
      updated: await $.clock.now(),
    }),
  )
}

export const register: Register = on => {
  let lastActivity = 0
  let resendOkUntil = 0
  let title = ''
  const nudged = new Set<number>()

  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'ship', description: 'Run the done-checklist before committing: /ship (or /ship off to hide it)' })
    await $.tool.register({
      name: 'ship_step',
      description: 'Record the outcome of one /ship checklist step so the user sees it above the prompt.',
      inputSchema: {
        type: 'object',
        properties: {
          step: { type: 'string', enum: SHIP_STEPS.map(([s]) => s) },
          state: { type: 'string', enum: ['pass', 'fail', 'skip'] },
          note: { type: 'string' },
        },
        required: ['step', 'state'],
      },
    })
    let tick = 0
    $.clock.every(5_000, () => {
      tick += 1
      void read($, activity).then(a => {
        if (a.running || tick % 6 === 0) $.ui.invalidate('ui.render')
      })
    })
    return next(e)
  })

  on('prompt.compose', async ($, e, next) => {
    const composed = await next(e)
    return { ...composed, sections: [...composed.sections, PROGRESS_SECTION] }
  }).catch(failOpen)

  on('turn.start', async ($, e, next) => {
    const now = await $.clock.now()
    await update($, activity, () => ({ running: true, startedAt: now, steps: 0, current: '', helpers: 0 }))
    return next(e)
  }).catch(failOpen)

  on('tool.call', async ($, e, next) => {
    const agentId = (e as any).agentId
    if (e.tool !== 'ToolSearch') {
      await update($, activity, a => (agentId ? a : { ...a, steps: a.steps + 1, current: label(e), helpers: a.helpers + (e.tool === 'Agent' ? 1 : 0) }))
    }
    return next(e)
  }).catch(failOpen)

  on('command.run', { command: 'goal' }, async ($, e, next) => {
    const result: any = await next(e)
    const text = e.args.trim()
    await update($, goal, () => (/^(clear|off|stop)$/i.test(text) ? '' : text))
    if (!text || /^(clear|off|stop)$/i.test(text)) return result
    return { ...result, context: [...(result.context ?? []), GOAL_BRIEF] }
  }).catch(failOpen)

  on('prompt.submit', async ($, e, next) => {
    if (!FROM_USER.has(e.origin.kind)) return next(e)
    if (!title) title = e.text.replace(/\s+/g, ' ').slice(0, 60)
    await update($, suggestions, () => [])
    const m = await read($, meter)
    if (!m || m.tokens < BIG_CHAT || !lastActivity) return next(e)
    const now = await $.clock.now()
    if (now - lastActivity < CACHE_TTL_MS || now < resendOkUntil) return next(e)
    resendOkUntil = now + RESEND_WINDOW_MS
    await $.prompt.fill({ text: e.text })
    $.ui.toast(
      `This ${k(m.tokens)} chat sat idle over an hour, so the next message re-reads everything at full price (≈${usd(m.writeUsd)}). Press Enter again to send anyway, or press handoff and start fresh.`,
      { timeoutMs: 20_000 },
    )
    return { drop: 'cold cache: confirm by sending again' }
  }).catch(failOpen)

  on('turn.complete', async ($, e, next) => {
    const result = await next(e)
    if ((e as any).agentId) return result
    await update($, activity, a => ({ ...a, running: false }))
    const usage = await $.session.usage()
    const tokens = usage.context.tokens ?? 0
    lastActivity = await $.clock.now()
    const [read$, write$] = prices(await $.session.model())
    const limits = usage.rateLimits
      .filter(l => LIMIT_LABELS[l.kind])
      .map(l => `${LIMIT_LABELS[l.kind]} ${Math.round(l.percentUsed)}%`)
      .join(' · ')
    await update($, meter, () => ({
      tokens,
      readUsd: (tokens * read$) / 1e6,
      writeUsd: (tokens * write$) / 1e6,
      sessionUsd: usage.cost ? usage.cost.usd : null,
      limits,
      lastActivity,
    }))
    for (const mark of NUDGES) {
      if (tokens >= mark && !nudged.has(mark)) {
        nudged.add(mark)
        $.ui.toast(`This chat is ${k(tokens)}. Every message re-reads all of it. Press handoff to continue in a fresh chat.`, { timeoutMs: 12_000 })
      }
    }

    const msgs = await $.session.messages()
    const last = [...msgs].reverse().find(m => m.role === 'assistant' && m.text.trim())
    const open = ((await read($, steps)) ?? []).filter(s => s.state === 'todo' || s.state === 'fail')
    if (last && open.length && DONE_WORDS.test(last.text)) {
      $.ui.toast(`Careful: the /ship checklist still has open steps (${open.map(s => s.label).join(', ')}).`, { timeoutMs: 12_000 })
    }
    if (last && last.text.length > 150) {
      const r = await $.model.complete({ model: 'haiku', system: NEXT_RULES, prompt: last.text.slice(-6000), maxTokens: 200, effort: 'low' })
      const lines = r.isAnswered
        ? r.text.split('\n').map(s => s.replace(/^[-*\d.)\s]+/, '').trim()).filter(s => s && s !== 'NONE' && s.length <= 70)
        : []
      await update($, suggestions, () => lines.slice(0, 3))
    }
    await publishChat($, title).catch(() => {})
    return result
  })

  on('tool.call', { tool: 'TaskCreate' }, async ($, e, next) => {
    const ran: any = await next(e)
    if ((e as any).agentId || ran.isError) return ran
    const id = String(ran.text ?? '').match(/#?(\d+)/)?.[1] ?? String(Date.now())
    const item: PlanItem = { id, title: e.subject, state: 'pending', size: SIZES[String((e.metadata as any)?.size ?? '').toUpperCase()] ?? 1 }
    const items = await read($, plan)
    if (items.every(i => i.state === 'completed')) {
      const now = await $.clock.now()
      await update($, planStart, () => now)
      await update($, plan, () => [item])
    } else {
      await update($, plan, list => [...list, item])
    }
    return ran
  }).catch(failOpen)

  on('tool.call', { tool: 'TaskUpdate' }, async ($, e, next) => {
    const ran: any = await next(e)
    if ((e as any).agentId || ran.isError || !e.status) return ran
    await update($, plan, list =>
      e.status === 'deleted'
        ? list.filter(i => i.id !== e.taskId)
        : list.map(i => (i.id === e.taskId ? { ...i, state: e.status as PlanItem['state'], title: e.subject ?? i.title, size: SIZES[String((e.metadata as any)?.size ?? '').toUpperCase()] ?? i.size } : i)),
    )
    return ran
  }).catch(failOpen)

  on('tool.call', { tool: 'TodoWrite' }, async ($, e, next) => {
    const ran: any = await next(e)
    if ((e as any).agentId || ran.isError) return ran
    if (!(await read($, planStart))) {
      const now = await $.clock.now()
      await update($, planStart, () => now)
    }
    await update($, plan, () => e.todos.map((t: any, i: number) => ({ id: String(i), title: t.content, state: t.status, size: 1 })))
    return ran
  }).catch(failOpen)

  on('command.run', { command: 'ship' }, async ($, e) => {
    if (e.args.trim() === 'off') {
      await update($, steps, () => null)
      return { text: 'Ship checklist hidden.' }
    }
    await update($, steps, () => SHIP_STEPS.map(([key, label]) => ({ key, label, state: 'todo' as const, note: '' })))
    return { context: [SHIP_BRIEF] }
  })

  on('tool.call', { tool: SHIP_TOOL }, async ($, e) => {
    const input = e as any
    await update($, steps, list => (list ?? []).map(s => (s.key === input.step ? { ...s, state: input.state, note: input.note ?? '' } : s)))
    return { result: 'recorded', text: `Recorded ${input.step}: ${input.state}` }
  }).catch(failOpen)

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.props.hasSurvey) return next(e)
    const m = await read($, meter)
    const items = await read($, plan)
    const ship = await read($, steps)
    const next3 = await read($, suggestions)
    const act = await read($, activity)
    const goalText = await read($, goal)
    if (!m && !items.length && !ship && !next3.length && !act.running && !goalText) return next(e)
    const { Box, Text, Button } = $.ui.resolve(e)
    const now = await $.clock.now()

    let cacheLine = null
    if (m) {
      const left = m.lastActivity + CACHE_TTL_MS - now
      const color = left <= 0 ? undefined : left < WARN_MS ? 'yellow' : 'green'
      const cache = left <= 0 ? '○ cache cold' : `● cache warm ${Math.ceil(left / 60_000)}m`
      const parts = [`ctx ${k(m.tokens)}`, `re-read ${usd(m.readUsd)}/msg`]
      if (m.limits) parts.push(m.limits)
      if (m.sessionUsd !== null) parts.push(`session ${usd(m.sessionUsd)}`)
      cacheLine = (
        <Box>
          <Text color={color} dimColor={left <= 0}>{cache}</Text>
          <Text dimColor> · {parts.join(' · ')}  </Text>
          <Button key="handoff" label="handoff" onPress={() => $.prompt.submit({ text: HANDOFF })} />
        </Box>
      )
    }

    const goalLine = goalText ? <Text color="cyan">◎ Goal: {goalText.slice(0, 90)}</Text> : null

    let planLine = null
    const total = items.length
    const done = items.filter(i => i.state === 'completed').length
    const weight = items.reduce((n, i) => n + i.size, 0)
    const doneWeight = items.filter(i => i.state === 'completed').reduce((n, i) => n + i.size, 0)
    if (total && done < total) {
      const start = await read($, planStart)
      const eta = done >= 2 && start && doneWeight ? Math.round((((now - start) / doneWeight) * (weight - doneWeight)) / 60_000) : null
      const current = items.find(i => i.state === 'in_progress')
      planLine = (
        <Text>
          {bar(doneWeight, weight)} {done} of {total} tasks · {Math.round((doneWeight / weight) * 100)}%{eta !== null ? ` · ~${eta}m left` : ''}
          {current ? ` · now: ${current.title}` : ''}
        </Text>
      )
    }

    const activityLine = act.running ? (
      <Text dimColor>
        ⏳ working {clockText(now - act.startedAt)} · {act.steps} steps{act.helpers ? ` · ${act.helpers} helper${act.helpers > 1 ? 's' : ''}` : ''}{act.current ? ` · ${act.current}` : ''}
      </Text>
    ) : null

    const mark = { todo: '·', pass: '✓', fail: '✗', skip: '–' } as const
    const shipLine = ship ? (
      <Box>
        <Text dimColor>ship </Text>
        {ship.map(s => (
          <Text color={s.state === 'fail' ? 'red' : s.state === 'pass' ? 'green' : undefined} dimColor={s.state === 'todo' || s.state === 'skip'}>
            {mark[s.state]}{s.label}{'  '}
          </Text>
        ))}
      </Box>
    ) : null

    const nextLine = next3.length && !e.props.isWorking ? (
      <Box>
        <Text dimColor>next: </Text>
        {next3.map((s, i) => (
          <Button key={`next-${i}`} label={s} onPress={() => $.prompt.fill({ text: s })} />
        ))}
      </Box>
    ) : null

    return (
      <Box flexDirection="column">
        {cacheLine}
        {goalLine}
        {planLine}
        {activityLine}
        {shipLine}
        {nextLine}
      </Box>
    )
  })
}
