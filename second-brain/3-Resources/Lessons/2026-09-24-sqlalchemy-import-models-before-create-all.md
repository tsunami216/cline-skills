---
type: lesson
created: 2026-09-24
updated: 2026-09-24
tags: [sqlalchemy, fastapi, sqlite]
project: SkillBuilder
---

# Import every SQLAlchemy model before `create_all()`

## Context

Skill Builder FastAPI `lifespan` calls `init_db()` → `Base.metadata.create_all()`. Tables for apps/runs/tasks only register if those model modules were imported first.

## What we learned

Silent “API 500 / no such table” after adding a new model is usually a missing import in `main.py` lifespan, not a bad migration.

## Rule for next time

In the startup path, import **all** model classes before `create_all()`. Add a new model → add the import in the same PR. Prefer an explicit `models/__init__.py` barrel if the list keeps growing.

## Related

- `Skill_builder/app/main.py` lifespan
- [[../1-Projects/SkillBuilder/architecture|Skill Builder architecture]]
