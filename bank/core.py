"""In-memory bank: accounts, deposits, withdrawals and transfers."""

from dataclasses import dataclass

ACCOUNT_TYPES = ("checking", "savings")


class BankError(Exception):
    """Raised when a banking operation is not allowed."""


@dataclass
class Account:
    owner: str
    type: str
    limit: int
    balance: int = 0


class Bank:
    def __init__(self) -> None:
        self._accounts: dict[str, Account] = {}

    def reset(self) -> None:
        self._accounts.clear()

    def open_account(self, owner: str, type: str = "checking", limit: int = 100) -> None:
        if type not in ACCOUNT_TYPES:
            raise BankError(f"Unknown account type '{type}', expected one of {', '.join(ACCOUNT_TYPES)}.")
        if owner in self._accounts:
            raise BankError(f"Account '{owner}' already exists.")
        self._accounts[owner] = Account(owner, type, limit if type == "checking" else 0)

    def deposit(self, owner: str, amount: int) -> None:
        self._account(owner).balance += self._positive(amount)

    def withdraw(self, owner: str, amount: int) -> None:
        account = self._account(owner)
        amount = self._positive(amount)
        if account.balance - amount < -account.limit:
            raise BankError(
                f"Withdrawing {amount} from '{owner}' exceeds the limit: balance {account.balance}, limit {account.limit}."
            )
        account.balance -= amount

    def transfer(self, source: str, target: str, amount: int) -> None:
        self._account(target)
        self.withdraw(source, amount)
        self.deposit(target, amount)

    def balance(self, owner: str) -> int:
        return self._account(owner).balance

    def limit(self, owner: str) -> int:
        return self._account(owner).limit

    def account(self, owner: str) -> Account:
        return self._account(owner)

    def _account(self, owner: str) -> Account:
        try:
            return self._accounts[owner]
        except KeyError:
            raise BankError(f"No account for '{owner}'.") from None

    @staticmethod
    def _positive(amount: int) -> int:
        if amount <= 0:
            raise BankError(f"Amount must be positive, got {amount}.")
        return amount
