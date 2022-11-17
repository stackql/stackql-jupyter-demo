import pandas as pd
from io import StringIO
import psycopg2, json
from psycopg2.extras import RealDictCursor

conn = psycopg2.connect("dbname=stackql user=stackql host=localhost port=5444")

def run_query(query):
    cur = conn.cursor(cursor_factory=RealDictCursor)
    cur.execute(query)
    rows = cur.fetchall()
    cur.close()
    return json.dumps(rows)

def stackql(line, cell):
    query = StringIO(cell)
    return pd.read_json(run_query(query.read()))

def load_ipython_extension(ipython):
    """This function is called when the extension is
    loaded. It accepts an IPython InteractiveShell
    instance. We can register the magic with the
    `register_magic_function` method of the shell
    instance."""
    ipython.register_magic_function(stackql, 'cell')
