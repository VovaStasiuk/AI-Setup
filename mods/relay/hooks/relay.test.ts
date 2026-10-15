import { test, expect } from 'claude-code/testing'

const stubs = (on: any) => {
  on('process.run', () => ({ value: { exitCode: 0, stdout: 'feature/x\n', stderr: '' } }))
  on('session.root', () => ({ value: '/repo' }))
}

test('/delegate --bg briefs the model for a background helper', async ($, on) => {
  stubs(on)
  const r: any = await $.command.run({ command: 'delegate', args: 'BIZADM-171 --bg' } as any)
  const brief = r.context[0]
  expect(brief).toContain('Mode: background')
  expect(brief).toContain('/repo/.ai/tasks/TASK-<id>.md')
  expect(brief).toContain('feature/x')
  expect(brief).toContain('BIZADM-171')
})

test('/delegate without a flag asks watch or background', async ($, on) => {
  stubs(on)
  const r: any = await $.command.run({ command: 'delegate', args: 'fix the export' } as any)
  expect(r.context[0]).toContain('Watch it in a new chat, or run it in the background?')
})

test('/delegate --watch opens a visible chat', async ($, on) => {
  stubs(on)
  const r: any = await $.command.run({ command: 'delegate', args: '--watch BIZADM-9' } as any)
  expect(r.context[0]).toContain('Mode: watch')
})
