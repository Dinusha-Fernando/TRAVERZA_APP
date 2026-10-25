import asyncio
import asyncpg

async def main():
    conn = await asyncpg.connect("postgresql://traverza_user:zara07@localhost:5432/traverza_db")
    tables = await conn.fetch("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
        ORDER BY table_name
    """)
    print(f"Total tables: {len(tables)}")
    total_rows = 0
    for t in tables:
        tname = t['table_name']
        count = await conn.fetchval(f'SELECT count(*) FROM "{tname}"')
        total_rows += count
        if count > 0:
            print(f"  {tname:32}: {count} rows")
        else:
            print(f"  {tname:32}: (empty, ready)")
    print("-" * 50)
    print(f"Total populated records across database: {total_rows}")
    await conn.close()

if __name__ == "__main__":
    asyncio.run(main())
