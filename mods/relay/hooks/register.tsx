import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { RelayChat, RelayTask } from '../types'

const PANE = 'relay-tasks'
const SCAN_MS = 15_000
const tasks = atom({ plugin: 'relay', key: 'tasks' } as const, [] as RelayTask[])
const chats = atom({ plugin: 'relay', key: 'chats' } as const, [] as RelayChat[])
const CHAT_MAX_AGE_MIN = 12 * 60

function field(text: string, name: string) {
  const m = text.match(new RegExp(`^${name}:\\s*(.+)$`, 'mi'))
  return m ? m[1].trim() : ''
}

function brief(dir: string, branch: string, mode: string, what: string) {
  const how =
    mode === 'ask'
      ? `First ask the user one question with AskUserQuestion: "Watch it in a new chat, or run it in the background?" Recommend "watch" for big or risky work and "background" for small, well-specified work. Then continue with the chosen mode.`
      : `Mode: ${mode}.`
  return `The user ran /delegate for: ${what || '(no description given: use the task we just discussed)'}
${how}

Do this, briefly and without extra questions:
1. Pick an id: the ticket key if there is one (e.g. BIZADM-171), otherwise a short kebab-case slug.
2. Write ${dir}/TASK-<id>.md. Start with these lines:
   id: <id>
   title: <one line>
   mode: <watch|background>
   branch: ${branch || 'the current branch'}
   created: <ISO time>
   Then sections: Goal; Context (decisions from this chat, paths of the spec/plan/ADR to read first); Scope (in / out); Acceptance checks; Rules (stay on branch ${branch || 'as is'}, no worktree, no commits or pushes, follow the project's CLAUDE.md/AGENTS.md, lint every touched file); When done.
   "When done" must say: write ${dir}/RESULT-<id>.md whose first line is "status: done" or "status: blocked", then sections Summary, Files changed, Checks run (command and outcome), Not done / risks, Decisions needed. Plain language.
3. Background mode: start the project's implementer agent if one exists , otherwise general-purpose, with run_in_background true and the prompt "Read ${dir}/TASK-<id>.md and do it. Write the RESULT file it describes." Do not wait for it or poll it.
4. Watch mode: open a visible new Claude chat in the project folder. If the Terminal panel tools exist (open_terminal_tab, run_in_terminal), use them; otherwise run: osascript -e 'tell application "Terminal" to do script "cd <project root> && claude \\"Read .ai/tasks/TASK-<id>.md and do it. Write the RESULT file it describes.\\""'
5. Tell the user in one or two plain sentences what started and that /tasks shows progress. The result comes back here automatically.`
}

const announced = new Set<string>()
let firstScan = true

// Reads the progress files cockpit writes for every open chat
async function scanChats($: any) {
  const home = (await $.env.get('HOME')) || ''
  const dir = `${home}/.claude/mods-data/cockpit/chats`
  if (!home || !(await $.fs.exists(dir))) return
  const me = `${await $.session.id()}.json`
  const now = await $.clock.now()
  const list: RelayChat[] = []
  for (const entry of await $.fs.list(dir)) {
    if (!entry.name.endsWith('.json')) continue
    try {
      const d = JSON.parse(await $.fs.read(`${dir}/${entry.name}`))
      const ageMin = Math.round((now - d.updated) / 60_000)
      if (ageMin > CHAT_MAX_AGE_MIN) continue
      list.push({ title: d.title || '(untitled)', folder: d.folder || '', done: d.done || 0, total: d.total || 0, current: d.current || '', ageMin, isMe: entry.name === me })
    } catch {
      // A half-written file from another chat is skipped
    }
  }
  await update($, chats, () => list.sort((a, b) => a.ageMin - b.ageMin).slice(0, 12))
}

// Reads .ai/tasks and announces newly finished tasks
async function scan($: any) {
  await scanChats($).catch(() => {})
  const dir = `${await $.session.root()}/.ai/tasks`
  if (!(await $.fs.exists(dir))) return
  const names: string[] = (await $.fs.list(dir)).map((x: any) => x.name)
  const now = await $.clock.now()
  const list: RelayTask[] = []
  for (const name of names.filter(n => /^TASK-.+\.md$/.test(n))) {
    const id = name.slice(5, -3)
    const path = `${dir}/${name}`
    const text = await $.fs.read(path)
    const stat = await $.fs.stat(path)
    const resultName = `RESULT-${id}.md`
    let state: RelayTask['state'] = 'running'
    if (names.includes(resultName)) {
      const result = await $.fs.read(`${dir}/${resultName}`)
      state = /^status:\s*blocked/im.test(result) ? 'blocked' : 'done'
      if (!firstScan && !announced.has(id)) {
        announced.add(id)
        $.ui.toast(`Delegated task ${id} is ${state}.`, { timeoutMs: 10_000 })
        void $.prompt.submit({
          text: `[relay] Task ${id} finished (${state}). Read ${dir}/${resultName} and tell me in plain words what was done, what is left, and what needs my decision.`,
        })
      }
      if (firstScan) announced.add(id)
    }
    list.push({ id, title: field(text, 'title') || id, mode: field(text, 'mode'), state, ageMin: Math.round((now - stat.mtimeMs) / 60_000) })
  }
  firstScan = false
  await update($, tasks, () => list.sort((a, b) => a.ageMin - b.ageMin).slice(0, 30))
  const running = list.filter(t => t.state === 'running').length
  $.ui.status(running ? `tasks: ${running} running` : undefined)
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'delegate', description: 'Hand a task to a fresh implementer: /delegate <ticket or task> [--watch | --bg]' })
    await $.command.register({ name: 'tasks', description: 'Show delegated tasks and their status' })
    $.clock.every(SCAN_MS, () => scan($).catch(() => {}))
    void scan($).catch(() => {})
    return next(e)
  })

  on('command.run', { command: 'delegate' }, async ($, e) => {
    const args = e.args
    const mode = /--watch\b/.test(args) ? 'watch' : /--bg\b/.test(args) ? 'background' : 'ask'
    const what = args.replace(/--watch\b|--bg\b/g, '').trim()
    const dir = `${await $.session.root()}/.ai/tasks`
    const r = await $.process.run(['git', 'branch', '--show-current'], { timeoutMs: 10_000 })
    const branch = r.exitCode === 0 ? r.stdout.trim() : ''
    return { context: [brief(dir, branch, mode, what)] }
  })

  on('command.run', { command: 'tasks' }, async $ => {
    await scan($).catch(() => {})
    await $.ui.open({ id: PANE, title: 'Tasks and chats' })
    return { text: 'Opened the tasks and chats pane.' }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text } = $.ui.resolve(e)
    const list = await read($, tasks)
    const open = await read($, chats)
    const mark = { running: '…', done: '✓', blocked: '!' } as const
    const bar = (d: number, t: number) => (t ? '█'.repeat(Math.round((d / t) * 10)) + '░'.repeat(10 - Math.round((d / t) * 10)) : '')
    return (
      <Box flexDirection="column">
        <Text bold>Chats (last 12h)</Text>
        {open.length === 0 && <Text dimColor>No other chats reporting yet.</Text>}
        {open.map(c => (
          <Text dimColor={c.total > 0 && c.done === c.total}>
            {c.isMe ? '▸ ' : '  '}{c.folder} · {c.title}{c.total ? ` · ${bar(c.done, c.total)} ${c.done}/${c.total}` : ''}{c.current ? ` · ${c.current}` : ''} · {c.ageMin}m ago
          </Text>
        ))}
        <Text bold>Delegated tasks</Text>
        {list.length === 0 && <Text dimColor>No delegated tasks in .ai/tasks yet. Start one with /delegate.</Text>}
        {list.map(t => (
          <Text dimColor={t.state === 'done'}>
            {mark[t.state]} {t.id} · {t.title} · {t.mode || '?'} · {t.ageMin}m ago
          </Text>
        ))}
      </Box>
    )
  })
}
