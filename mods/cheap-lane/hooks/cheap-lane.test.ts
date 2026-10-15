import { test, expect } from 'claude-code/testing'

const DIFF = 'diff --git a/x.py b/x.py\n+print(1)\n'

const stubs = (on: any, models: string[]) => {
  on('process.run', ($: any, e: any) => {
    const args = e.argv.join(' ')
    const stdout = args.includes('--pretty') ? 'feat: earlier change\n' : args.includes('--stat') ? ' x.py | 1 +\n' : args.includes('--staged') ? DIFF : ''
    return { value: { exitCode: 0, stdout, stderr: '' } }
  })
  on('model.complete', ($: any, e: any) => {
    models.push(e.model)
    return { value: { isAnswered: true, text: 'feat: print one', usage: { input_tokens: 10, output_tokens: 5 } } }
  })
}

test('/commit-msg drafts with Haiku from the staged diff', async ($, on) => {
  const models: string[] = []
  stubs(on, models)
  const r: any = await $.command.run({ command: 'commit-msg', args: '' } as any)
  expect(r.text).toContain('feat: print one')
  expect(r.text).toContain('staged changes')
  expect(models).toEqual(['haiku'])
})

test('/quick without a question shows usage', async ($, on) => {
  stubs(on, [])
  const r: any = await $.command.run({ command: 'quick', args: '  ' } as any)
  expect(r.text).toContain('Usage')
})

test('/quick asks Sonnet', async ($, on) => {
  const models: string[] = []
  stubs(on, models)
  await $.command.run({ command: 'quick', args: 'what is a worktree?' } as any)
  expect(models).toEqual(['sonnet'])
})
