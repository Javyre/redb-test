use std::path::Path;

use redb::{Database, ReadableTable, TableDefinition};

const TABLE: TableDefinition<u64, u64> = TableDefinition::new("my_data");

fn main() {
    let db = Database::create(Path::new("./test.db")).unwrap();

    let last_key = {
        let rtx = db.begin_read().unwrap();
        let table = rtx.open_table(TABLE).unwrap();
        table.last().unwrap().map_or(0, |(k, _)| k.value())
    };

    dbg!(last_key);
    //return;

    let tx = db.begin_write().unwrap();
    {
        let mut table = tx.open_table(TABLE).unwrap();
        for i in 0..1000000 {
            table.insert(/* last_key + */ i, 1).unwrap();
        }
    }
    tx.commit().unwrap();

    println!("Hello, world!");
}
