"""Robot Framework keywords for the demo bank.

By default the keywords work on an in-memory bank. When the variable ``${BANK_URL}`` (or the environment
variable ``BANK_URL``) is set, they talk to the bank web service instead.
"""

import os
from typing import Literal

from robot.api.deco import keyword, library
from robot.libraries.BuiltIn import BuiltIn

from bank.client import HttpBank
from bank.core import Bank, BankError


@library(scope="TEST")
class BankLibrary:
    """Open accounts, move money and check balances.

    Every test starts with an empty bank.
    """

    def __init__(self) -> None:
        self._bank: Bank | HttpBank | None = None

    @property
    def bank(self) -> Bank | HttpBank:
        if self._bank is None:
            url = self._bank_url()
            self._bank = HttpBank(url) if url else Bank()
            self._bank.reset()
        return self._bank

    @keyword
    def open_account(self, owner: str, type: Literal["checking", "savings"] = "checking", limit: int = 100) -> None:
        """Opens an empty account for ``owner``.

        ``checking`` accounts may be overdrawn up to ``limit``; ``savings`` accounts cannot be overdrawn.
        """
        self.bank.open_account(owner, type, limit)

    @keyword
    def deposit(self, owner: str, amount: int) -> None:
        """Adds ``amount`` to the account of ``owner``."""
        self.bank.deposit(owner, amount)

    @keyword
    def withdraw(self, owner: str, amount: int) -> None:
        """Takes ``amount`` from the account of ``owner``. Fails if the overdraft limit would be exceeded."""
        self.bank.withdraw(owner, amount)

    @keyword
    def transfer(self, source: str, target: str, amount: int) -> None:
        """Moves ``amount`` from ``source`` to ``target``."""
        self.bank.transfer(source, target, amount)

    @keyword
    def get_balance(self, owner: str) -> int:
        """Returns the current balance of ``owner``."""
        return self.bank.balance(owner)

    @keyword
    def get_limit(self, owner: str) -> int:
        """Returns the overdraft limit of ``owner`` (always 0 for savings accounts)."""
        return self.bank.limit(owner)

    @keyword
    def balance_should_be(self, owner: str, expected: int) -> None:
        """Fails unless the balance of ``owner`` equals ``expected``."""
        actual = self.bank.balance(owner)
        if actual != expected:
            raise AssertionError(f"Balance of '{owner}' should be {expected} but was {actual}.")

    @keyword
    def withdrawal_should_fail(self, owner: str, amount: int) -> None:
        """Fails if withdrawing ``amount`` from ``owner`` succeeds."""
        try:
            self.bank.withdraw(owner, amount)
        except BankError:
            return
        raise AssertionError(f"Withdrawing {amount} from '{owner}' should have failed but succeeded.")

    @keyword
    def service_should_be_healthy(self) -> None:
        """Fails unless the bank web service configured in ``${BANK_URL}`` answers."""
        url = self._bank_url()
        if not url:
            raise AssertionError("${BANK_URL} is not set. Run with the 'service' profile: robotcode -p service robot")
        if not HttpBank(url).healthy():
            raise AssertionError(f"The bank service at {url} does not answer. Is it running?")

    @staticmethod
    def _bank_url() -> str:
        return BuiltIn().get_variable_value("${BANK_URL}", os.environ.get("BANK_URL", "")) or ""
