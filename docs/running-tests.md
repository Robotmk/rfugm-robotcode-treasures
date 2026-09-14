# Running the tests

*Last updated: some time ago.*

| What | Command |
|---|---|
| Quick check while developing | `robot --exclude integration --include smoke tests` |
| Regression, in-memory | `robot --exclude integration --include regression tests` |
| Everything against the service | `robot --variable BANK_URL:http://localhost:8765 tests` |
| Regression against the service | `robot --variable BANK_URL:http://localhost:8765 --include regression tests` |
| Like CI | `robot --exclude integration --exclude wip --outputdir results/ci --xunit xunit.xml --console dotted tests` |

Start the service first for the `BANK_URL` variants: `python -m bank.service --port 8765`.
