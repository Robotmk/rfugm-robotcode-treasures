"""Behaviour tests for the demo bank — run against the in-memory core and the HTTP service.

Maintainer tool, not part of the workshop exercises:  python scripts/selftest_bank.py
"""

import sys
import threading
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from bank.client import HttpBank  # noqa: E402
from bank.core import Bank, BankError  # noqa: E402
from bank.service import create_server  # noqa: E402


class BankBehaviour:
    def make_bank(self):
        raise NotImplementedError

    def setUp(self):
        self.bank = self.make_bank()
        self.bank.reset()

    def test_new_account_starts_empty(self):
        self.bank.open_account("alice")
        self.assertEqual(self.bank.balance("alice"), 0)

    def test_deposit_and_withdraw(self):
        self.bank.open_account("alice")
        self.bank.deposit("alice", 100)
        self.bank.withdraw("alice", 30)
        self.assertEqual(self.bank.balance("alice"), 70)

    def test_transfer(self):
        self.bank.open_account("alice")
        self.bank.open_account("bob", type="savings")
        self.bank.deposit("alice", 100)
        self.bank.transfer("alice", "bob", 30)
        self.assertEqual((self.bank.balance("alice"), self.bank.balance("bob")), (70, 30))

    def test_checking_can_be_overdrawn_exactly_to_limit(self):
        self.bank.open_account("alice", limit=100)
        self.bank.withdraw("alice", 100)
        self.assertEqual(self.bank.balance("alice"), -100)
        self.assertEqual(self.bank.limit("alice"), 100)

    def test_checking_cannot_exceed_limit(self):
        self.bank.open_account("alice", limit=100)
        with self.assertRaises(BankError):
            self.bank.withdraw("alice", 101)

    def test_savings_has_no_overdraft(self):
        self.bank.open_account("carol", type="savings", limit=500)
        self.assertEqual(self.bank.limit("carol"), 0)
        with self.assertRaises(BankError):
            self.bank.withdraw("carol", 1)

    def test_invalid_operations(self):
        self.bank.open_account("alice")
        for call in (
            lambda: self.bank.open_account("alice"),
            lambda: self.bank.deposit("nobody", 1),
            lambda: self.bank.deposit("alice", 0),
            lambda: self.bank.open_account("dave", type="gold"),
        ):
            with self.assertRaises(BankError):
                call()

    def test_reset_removes_accounts(self):
        self.bank.open_account("alice")
        self.bank.reset()
        with self.assertRaises(BankError):
            self.bank.balance("alice")


class InMemoryBankTest(BankBehaviour, unittest.TestCase):
    def make_bank(self):
        return Bank()


class HttpBankTest(BankBehaviour, unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = create_server(port=0)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()

    def make_bank(self):
        return HttpBank(f"http://127.0.0.1:{self.server.server_address[1]}")

    def test_health(self):
        self.assertTrue(self.bank.healthy())


if __name__ == "__main__":
    unittest.main(verbosity=1)
