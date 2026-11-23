"""Tests for durable, atomic synthetic approval-reference consumption."""
import os
import tempfile
import unittest

from approval_store import ApprovalStoreNotConfigured, SQLiteApprovalStore


class SQLiteApprovalStoreTests(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp_dir.cleanup)
        self.path = os.path.join(self.temp_dir.name, "state", "approvals.sqlite3")
        self.store = SQLiteApprovalStore(self.path)

    def consume(self, *references):
        return self.store.consume_many(
            references,
            consumed_at="2027-06-01T12:00:00+00:00",
            subject_id="synthetic-subject",
            policy_id="synthetic-policy",
            policy_version="1",
        )

    def test_consumption_survives_new_store_instance(self):
        self.assertTrue(self.consume("approval-1"))
        reopened = SQLiteApprovalStore(self.path)
        self.assertFalse(reopened.consume_many(
            ["approval-1"],
            consumed_at="2027-06-01T12:01:00+00:00",
            subject_id="synthetic-subject",
            policy_id="synthetic-policy",
            policy_version="1",
        ))

    def test_multi_reference_consumption_is_atomic(self):
        self.assertTrue(self.consume("already-used"))
        self.assertFalse(self.consume("fresh", "already-used"))
        # The failed batch must not partially consume "fresh".
        self.assertTrue(self.consume("fresh"))

    def test_empty_or_duplicate_batch_is_rejected(self):
        self.assertFalse(self.consume())
        self.assertFalse(self.consume("same", "same"))

    def test_missing_database_path_is_not_accepted(self):
        with self.assertRaises(ApprovalStoreNotConfigured):
            SQLiteApprovalStore(None)

    def test_revocation_persists_and_prevents_consumption(self):
        self.assertTrue(self.store.revoke(
            "revoked-approval",
            revoked_at="2027-06-01T12:00:00+00:00",
            revoked_by="synthetic-authority",
            reason="withdrawn",
        ))
        self.assertTrue(self.store.is_revoked("revoked-approval"))
        self.assertFalse(self.consume("revoked-approval"))

    def test_duplicate_revocation_is_rejected(self):
        kwargs = {
            "revoked_at": "2027-06-01T12:00:00+00:00",
            "revoked_by": "synthetic-authority",
            "reason": "withdrawn",
        }
        self.assertTrue(self.store.revoke("approval-x", **kwargs))
        self.assertFalse(self.store.revoke("approval-x", **kwargs))

    def test_in_memory_database_is_not_accepted(self):
        with self.assertRaises(ApprovalStoreNotConfigured):
            SQLiteApprovalStore(":memory:")


if __name__ == "__main__":
    unittest.main()
