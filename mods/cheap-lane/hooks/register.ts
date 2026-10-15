import type { Register } from 'claude-code'

const MAX_DIFF = 80_000

const COMMIT_RULES = `Write a git commit message for the diff below.
- Match the style of the recent commit subjects shown (Conventional Commits if they use it).
- Subject line at most 72 characters, imperative, no trailing period.
- Add a short body of bullet points only when the change needs explaining.
- Never add Co-Authored-By, "Generated with" or any AI attribution.
- Output only the commit message, nothing else.`

const QUICK_RULES = `Answer the question briefly in plain, everyday language, like a senior teammate in chat.
Explain any technical term in what it means in practice, with one short real example. No headers.`

const EXPLAIN_RULES = `Rewrite the assistant answer below so a busy developer understands it on first read.
- Start with what it means for them and what (if anything) they need to do.
- Replace jargon with plain words; keep exact names of files, commands and tickets.
- Add one short concrete example if it helps. Keep it shorter than the original.`

async function git($: any, args: string[]) {
  const r = await $.process.run(['git', ...args], { timeoutMs: 20_000 })
  return r.exitCode === 0 ? r.stdout : ''
}

async function ask($: any, model: string, system: string, prompt: string, effort: string) {
  const r = await $.model.complete({ model, system, prompt, maxTokens: 1500, effort })
  return r.isAnswered ? r.text.trim() : `Could not get an answer (${r.reason}). Try again in a moment.`
}

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.command.register({ name: 'commit-msg', description: 'Draft a commit message for staged changes (or all changes) with Haiku' })
    await $.command.register({ name: 'quick', description: 'Ask Sonnet a quick question without using this chat: /quick <question>' })
    await $.command.register({ name: 'explain', description: 'Rewrite the last answer in plain words (Sonnet)' })
    return next(e)
  })

  on('command.run', { command: 'commit-msg' }, async $ => {
    let diff = await git($, ['diff', '--staged'])
    let staged = true
    if (!diff.trim()) {
      diff = await git($, ['diff'])
      staged = false
    }
    if (!diff.trim()) return { text: 'Nothing to commit: no staged or unstaged changes.' }
    const stat = await git($, staged ? ['diff', '--staged', '--stat'] : ['diff', '--stat'])
    const log = await git($, ['log', '-8', '--pretty=%s'])
    const body = diff.length > MAX_DIFF ? `${diff.slice(0, MAX_DIFF)}\n…(diff cut, see stat)` : diff
    const msg = await ask($, 'haiku', COMMIT_RULES, `Recent subjects:\n${log}\nStat:\n${stat}\nDiff:\n${body}`, 'low')
    const scope = staged ? 'staged changes' : 'all unstaged changes (nothing is staged)'
    return { text: `Commit message for ${scope}:\n\n\`\`\`\n${msg}\n\`\`\`` }
  })

  on('command.run', { command: 'quick' }, async ($, e) => {
    const q = e.args.trim()
    if (!q) return { text: 'Usage: /quick <your question>' }
    return { text: await ask($, 'sonnet', QUICK_RULES, q, 'low') }
  })

  on('command.run', { command: 'explain' }, async $ => {
    const msgs = await $.session.messages()
    const last = [...msgs].reverse().find(m => m.role === 'assistant' && m.text.trim())
    if (!last) return { text: 'There is no answer to explain yet.' }
    return { text: await ask($, 'sonnet', EXPLAIN_RULES, last.text, 'medium') }
  })
}
