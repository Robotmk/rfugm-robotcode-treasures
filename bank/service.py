"""The bank as a small JSON web service (standard library only).

    python -m bank.service [--port 8765]
"""

import argparse
import json
import os
import re
import threading
from dataclasses import asdict
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from bank.core import Bank, BankError

DEFAULT_PORT = 8765


class BankRequestHandler(BaseHTTPRequestHandler):
    bank: Bank
    lock: threading.Lock

    def do_GET(self) -> None:
        if self.path == "/health":
            return self._reply(200, {"status": "ok"})
        if match := re.fullmatch(r"/accounts/([^/]+)", self.path):
            return self._call(lambda: asdict(self.bank.account(match[1])))
        self._reply(404, {"error": f"Not found: {self.path}"})

    def do_POST(self) -> None:
        body = self._body()
        routes = {
            r"/reset": lambda: self.bank.reset(),
            r"/accounts": lambda: self.bank.open_account(body["owner"], body.get("type", "checking"), body.get("limit", 100)),
            r"/accounts/([^/]+)/deposit": lambda owner: self.bank.deposit(owner, body["amount"]),
            r"/accounts/([^/]+)/withdraw": lambda owner: self.bank.withdraw(owner, body["amount"]),
            r"/transfers": lambda: self.bank.transfer(body["source"], body["target"], body["amount"]),
        }
        for pattern, action in routes.items():
            if match := re.fullmatch(pattern, self.path):
                return self._call(lambda: action(*match.groups()))
        self._reply(404, {"error": f"Not found: {self.path}"})

    def _call(self, action) -> None:
        try:
            with self.lock:
                result = action()
        except BankError as error:
            return self._reply(400, {"error": str(error)})
        except (KeyError, TypeError) as error:
            return self._reply(400, {"error": f"Invalid request: {error}"})
        self._reply(200, result if result is not None else {"status": "ok"})

    def _body(self) -> dict:
        length = int(self.headers.get("Content-Length") or 0)
        return json.loads(self.rfile.read(length) or b"{}")

    def _reply(self, status: int, payload: dict) -> None:
        data = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, format: str, *args) -> None:
        if os.environ.get("BANK_SERVICE_VERBOSE"):
            super().log_message(format, *args)


def create_server(port: int = DEFAULT_PORT, host: str = "127.0.0.1") -> ThreadingHTTPServer:
    handler = type("Handler", (BankRequestHandler,), {"bank": Bank(), "lock": threading.Lock()})
    return ThreadingHTTPServer((host, port), handler)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the demo bank as a JSON web service.")
    parser.add_argument("--port", type=int, default=int(os.environ.get("BANK_PORT", DEFAULT_PORT)))
    args = parser.parse_args()
    server = create_server(args.port)
    print(f"Bank service listening on http://127.0.0.1:{args.port}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
