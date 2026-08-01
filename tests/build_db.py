"""Build a seeded lift.db from the schema files.

Usage: python tests/build_db.py [path/to/lift.db]
"""
import sqlite3
import sys
from pathlib import Path

SCHEMA_DIR = Path(__file__).resolve().parent.parent / "schema"


def build(db_path=":memory:"):
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON")
    for script in sorted(SCHEMA_DIR.glob("*.sql")):
        conn.executescript(script.read_text(encoding="utf-8"))
    conn.commit()
    return conn


if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "lift.db"
    if Path(target).exists():
        sys.exit(f"{target} already exists, delete it first")
    build(target).close()
    print(f"built {target}")
