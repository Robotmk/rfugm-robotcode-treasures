# Solution — Chapter 7

## Findings on the topic branch

```text
$ robotcode analyze code --collect-unused; echo "exit code: $?"
resources/banking.resource:20:7: [WARNING] VariableNotUsed: Variable '${message}' is not used.
resources/banking.resource:26:1: [WARNING] KeywordNotUsed: Keyword 'Close Account' is not used.
tests/accounts/basics.robot:26:38: [ERROR] VariableNotFound: Variable '${LAST_TRANSFER_AMOUNT}' not found.
Files: 4, Errors: 1, Warnings: 2, Infos: 0, Hints: 0
exit code: 3
```

Exit code 3 = 1 (errors) | 2 (warnings).

## Changes

- `resources/banking.resource`: removed the unused keyword `Close Account` and the unused `${message}` assignment.
- `tests/accounts/basics.robot`: the runtime variable stays, with a line-level modifier:

  ```robotframework
      Should Be Equal As Integers    ${LAST_TRANSFER_AMOUNT}    30    # robotcode: ignore[VariableNotFound]
  ```

  Why not `ignore = ["VariableNotFound"]` in `robot.toml`? That would hide *every* missing variable in the project,
  including real typos. Silence the one known case, not the whole rule.

```text
$ robotcode analyze code --collect-unused; echo "exit code: $?"
Files: 4, Errors: 0, Warnings: 0, Infos: 0, Hints: 0
exit code: 0
```

## Bonus

On the topic branch:

```text
$ robotcode analyze code --collect-unused --output-format github --exit-code-mask warn,info,hint; echo "exit code: $?"
::warning file=resources/banking.resource,line=20,endLine=20,col=7,endColumn=14,title=VariableNotUsed::Variable '${message}' is not used.
::warning file=resources/banking.resource,line=26,endLine=26,col=1,endColumn=14,title=KeywordNotUsed::Keyword 'Close Account' is not used.
::error file=tests/accounts/basics.robot,line=26,endLine=26,col=38,endColumn=58,title=VariableNotFound::Variable '${LAST_TRANSFER_AMOUNT}' not found.
exit code: 1

$ robotcode analyze code --collect-unused --output-format sarif --output-file robotcode.sarif
$ jq '.runs[0].results | length' robotcode.sarif
3
```

Warnings still show up as annotations, but only the error makes the job fail (exit code 1 instead of 3).
