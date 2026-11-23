"""SQLite-backed one-time-use store for the isolated synthetic API prototype.

This is a local prototype primitive, not a production consent or authorization
service. Use a local durable filesystem path; do not put the database on an
unvalidated network filesystem.
"""
from __future__ import annotations

import os
import sqlite3
from pathlib import Path
from typing import Iterable


class ApprovalStoreNotConfigured(RuntimeError):
    pass


class SQLiteApprovalStore:
    """Atomically consume approval references using a UNIQUE primary key."""

    def __init__(self, database_path: str | None = None):
        self.database_path = database_path or os.environ.get("AIDORA_APPROVAL_STORE_DB")
        if not self.database_path:
            raise ApprovalStoreNotConfigured(
                "AIDORA_APPROVAL_STORE_DB must point to a durable local database file"
            )
        if self.database_path == ":memory:":
            raise ApprovalStoreNotConfigured("in-memory replay stores are not accepted")

    def _connect(self):
        path = Path(self.database_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        connection = sqlite3.connect(
            self.database_path, timeout=10.0, isolation_level=None
        )
        connection.execute("PRAGMA busy_timeout = 10000")
        connection.execute("PRAGMA journal_mode = WAL")
        connection.execute(
            """
            CREATE TABLE IF NOT EXISTS consumed_approval_references (
                reference TEXT PRIMARY KEY,
                consumed_at TEXT NOT NULL,
                subject_id TEXT NOT NULL,
                policy_id TEXT NOT NULL,
                policy_version TEXT NOT NULL
            )
            """
        )
        return connection

    def consume_many(
        self,
        references: Iterable[str],
        *,
        consumed_at: str,
        subject_id: str,
        policy_id: str,
        policy_version: str,
    ) -> bool:
        """Consume all refs atomically; return False if any were already used."""
        refs = tuple(references)
        if not refs or len(refs) != len(set(refs)):
            return False
        if any(not isinstance(ref, str) or not ref for ref in refs):
            return False

        connection = self._connect()
        try:
            # BEGIN IMMEDIATE serializes writers before checking/inserting.
            # The primary key is the final duplicate/replay enforcement.
            connection.execute("BEGIN IMMEDIATE")
            placeholders = ",".join("?" for _ in refs)
            existing = connection.execute(
                f"SELECT reference FROM consumed_approval_references WHERE reference IN ({placeholders})",
                refs,
            ).fetchone()
            if existing:
                connection.execute("ROLLBACK")
                return False
            connection.executemany(
                """
                INSERT INTO consumed_approval_references
                    (reference, consumed_at, subject_id, policy_id, policy_version)
                VALUES (?, ?, ?, ?, ?)
                """,
                (
                    (ref, consumed_at, subject_id, policy_id, policy_version)
                    for ref in refs
                ),
            )
            connection.execute("COMMIT")
            return True
        except sqlite3.IntegrityError:
            connection.execute("ROLLBACK")
            return False
        except Exception:
            if connection.in_transaction:
                connection.execute("ROLLBACK")
            raise
        finally:
            connection.close()
