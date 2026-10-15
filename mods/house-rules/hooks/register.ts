import type { Register } from 'claude-code'

// Only git at a command position (start, after ; && || | ( or $( ), not inside text
const GIT_MUTATION = /(?:^|[;&|(\n]|\$\()\s*git(?:\s+-C\s+\S+)*\s+(commit|push|rebase|reset|checkout|switch|restore|clean|merge|cherry-pick)\b/
const NEVER = [
  { re: /--create-db\b/, why: 'it rebuilds the test database (about an hour)' },
  { re: /-o\s+['"]?addopts|addopts=/, why: 'overriding pytest addopts drops --reuse-db and rebuilds the test database' },
]
const ACTION_WORDS = /\b(do|fix|change|update|implement|add|remove|delete|rename|write|edit|apply|build|create|make|go ahead|yes|please)\b/i
const FROM_USER = new Set(['composer', 'bridge'])

// A broken guard must never block normal work
function failOpen($: any, e: any, next: any) {
  return next(e)
}

export const register: Register = on => {
  let lastPrompt = ''

  on('prompt.submit', ($, e, next) => {
    if (FROM_USER.has(e.origin.kind)) lastPrompt = e.text
    return next(e)
  }).catch(failOpen)

  const asked = (word: string) => new RegExp(`\\b${word}`, 'i').test(lastPrompt)
  const isQuestion = () => {
    const t = lastPrompt.trim()
    return t.endsWith('?') && !ACTION_WORDS.test(t)
  }

  on('tool.call', { tool: 'Bash' }, async ($, e, next) => {
    const cmd = e.command
    for (const rule of NEVER) {
      if (rule.re.test(cmd)) return { deny: `house-rules: blocked because ${rule.why}. Use the normal test command.` }
    }
    const git = cmd.match(GIT_MUTATION)
    if (git && !asked(git[1])) {
      return { deny: `house-rules: "git ${git[1]}" needs the user to ask for it in their message. Show the diff and ask first.` }
    }
    return next(e)
  }).catch(failOpen)

  on('tool.call', { tool: 'EnterWorktree' }, ($, e, next) =>
    asked('worktree') ? next(e) : { deny: 'house-rules: stay on the current branch and folder. The user did not ask for a worktree.' },
  ).catch(failOpen)

  on('tool.call', { tool: 'Agent' }, ($, e, next) =>
    e.isolation === 'worktree' && !asked('worktree')
      ? { deny: 'house-rules: run helpers on the current branch. Drop isolation: "worktree".' }
      : next(e),
  ).catch(failOpen)

  for (const tool of ['Edit', 'Write', 'NotebookEdit'] as const) {
    on('tool.call', { tool }, ($, e, next) =>
      isQuestion()
        ? { deny: 'house-rules: the user asked a question. Answer it, and ask before changing files.' }
        : next(e),
    ).catch(failOpen)
  }
}
