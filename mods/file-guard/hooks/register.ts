import type { Register } from 'claude-code'

const WINDOW_MS = 30 * 60_000

function target(e: any): string {
  return e.file_path ?? e.notebook_path ?? ''
}

// Another chat's record of a recent edit to this path, or null
export function recentEdit(data: any, path: string, now: number): { minutes: number; chat: string } | null {
  const at = data?.files?.[path]
  return at && now - at < WINDOW_MS ? { minutes: Math.round((now - at) / 60_000), chat: data.title || '' } : null
}

// Each chat keeps its own file of { path: lastEditMs } so chats never overwrite each other
async function editsDir($: any) {
  const home = (await $.env.get('HOME')) || ''
  return home ? `${home}/.claude/mods-data/file-guard` : ''
}

async function otherChatEdit($: any, path: string) {
  const dir = await editsDir($)
  if (!dir || !(await $.fs.exists(dir))) return null
  const me = `${await $.session.id()}.json`
  const now = await $.clock.now()
  for (const entry of await $.fs.list(dir)) {
    if (entry.name === me || !entry.name.endsWith('.json')) continue
    try {
      const hit = recentEdit(JSON.parse(await $.fs.read(`${dir}/${entry.name}`)), path, now)
      if (hit) return { ...hit, chat: hit.chat || entry.name.slice(0, 8) }
    } catch {
      // A half-written file from another chat is skipped
    }
  }
  return null
}

async function recordEdit($: any, path: string, title: string) {
  const dir = await editsDir($)
  if (!dir) return
  await $.process.run(['mkdir', '-p', dir], { timeoutMs: 5_000 })
  const file = `${dir}/${await $.session.id()}.json`
  const now = await $.clock.now()
  let files: Record<string, number> = {}
  if (await $.fs.exists(file)) {
    try {
      files = JSON.parse(await $.fs.read(file)).files ?? {}
    } catch {
      files = {}
    }
  }
  files[path] = now
  for (const [p, at] of Object.entries(files)) if (now - at > WINDOW_MS) delete files[p]
  await $.fs.write(file, JSON.stringify({ title, files }))
}

// A broken guard must never block an edit
function failOpen($: any, e: any, next: any) {
  return next(e)
}

export const register: Register = on => {
  let title = ''

  on('prompt.submit', ($, e, next) => {
    if (!title && e.origin.kind === 'composer') title = e.text.replace(/\s+/g, ' ').slice(0, 50)
    return next(e)
  }).catch(failOpen)

  on('classic.PreToolUse', { tool: ['Edit', 'Write', 'NotebookEdit'] }, async ($, e, next) => {
    const path = target(e)
    const hit = path ? await otherChatEdit($, path) : null
    if (!hit) return next(e)
    return { ask: `Another open chat ("${hit.chat}") changed ${path.split('/').pop()} ${hit.minutes} min ago. Edit it anyway?` }
  }).catch(failOpen)

  on('tool.call', { tool: ['Edit', 'Write', 'NotebookEdit'] }, async ($, e, next) => {
    const ran: any = await next(e)
    const path = target(e)
    if (path && !ran.isError && !ran.deny) await recordEdit($, path, title).catch(() => {})
    return ran
  }).catch(failOpen)
}
