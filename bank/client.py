"""Talks to the bank service with the same interface as bank.core.Bank."""

import json
import urllib.error
import urllib.request

from bank.core import BankError


class HttpBank:
    def __init__(self, base_url: str, timeout: float = 5.0) -> None:
        self.base_url = base_url.rstrip("/")
        self.timeout = timeout

    def healthy(self) -> bool:
        try:
            return self._request("GET", "/health").get("status") == "ok"
        except (BankError, OSError):
            return False

    def reset(self) -> None:
        self._request("POST", "/reset")

    def open_account(self, owner: str, type: str = "checking", limit: int = 100) -> None:
        self._request("POST", "/accounts", {"owner": owner, "type": type, "limit": limit})

    def deposit(self, owner: str, amount: int) -> None:
        self._request("POST", f"/accounts/{owner}/deposit", {"amount": amount})

    def withdraw(self, owner: str, amount: int) -> None:
        self._request("POST", f"/accounts/{owner}/withdraw", {"amount": amount})

    def transfer(self, source: str, target: str, amount: int) -> None:
        self._request("POST", "/transfers", {"source": source, "target": target, "amount": amount})

    def balance(self, owner: str) -> int:
        return self._request("GET", f"/accounts/{owner}")["balance"]

    def limit(self, owner: str) -> int:
        return self._request("GET", f"/accounts/{owner}")["limit"]

    def _request(self, method: str, path: str, payload: dict | None = None) -> dict:
        data = json.dumps(payload).encode() if payload is not None else None
        request = urllib.request.Request(
            self.base_url + path, data=data, method=method, headers={"Content-Type": "application/json"}
        )
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                return json.loads(response.read() or b"{}")
        except urllib.error.HTTPError as error:
            message = json.loads(error.read() or b"{}").get("error", str(error))
            raise BankError(message) from None
