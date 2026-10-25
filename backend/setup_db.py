import asyncio

import asyncpg


async def main():
    conn = await asyncpg.connect("postgresql://postgres:zara07@localhost:5432/postgres")

    # 1. Create or update user traverza_user
    user_exists = await conn.fetchval("SELECT 1 FROM pg_roles WHERE rolname = 'traverza_user'")
    if not user_exists:
        await conn.execute("CREATE USER traverza_user WITH PASSWORD 'zara07' SUPERUSER CREATEDB;")
        print("Created user 'traverza_user' with SUPERUSER privileges")
    else:
        await conn.execute("ALTER USER traverza_user WITH PASSWORD 'zara07' SUPERUSER CREATEDB;")
        print("Updated user 'traverza_user' password to zara07")

    # 2. Create database traverza_db if not exists
    db_exists = await conn.fetchval("SELECT 1 FROM pg_database WHERE datname = 'traverza_db'")
    if not db_exists:
        await conn.execute("CREATE DATABASE traverza_db OWNER traverza_user;")
        print("Created database 'traverza_db' owned by 'traverza_user'")
    else:
        print("Database 'traverza_db' already exists")

    await conn.close()

    # 3. Test connecting directly to traverza_db and list tables
    tconn = await asyncpg.connect("postgresql://traverza_user:zara07@localhost:5432/traverza_db")
    print("Connected successfully to traverza_db as traverza_user!")

    rows = await tconn.fetch(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name"
    )
    print(f"Total tables in traverza_db: {len(rows)}")
    for r in rows:
        print(f"  - {r['table_name']}")

    await tconn.close()

if __name__ == "__main__":
    asyncio.run(main())
