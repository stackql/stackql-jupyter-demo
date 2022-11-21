from __future__ import print_function
import pandas as pd
import psycopg2, json
from psycopg2.extras import RealDictCursor
from IPython.core.magic import (Magics, magics_class, line_cell_magic)
from io import StringIO
from string import Template

conn = psycopg2.connect("dbname=stackql user=stackql host=localhost port=5444")

@magics_class
class StackqlMagic(Magics):

    def get_rendered_query(self, data):
        t = Template(StringIO(data).read())
        rendered = t.substitute(self.shell.user_ns)
        return rendered

    def run_query(self, query):
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute(query)
        rows = cur.fetchall()
        cur.close()
        return pd.read_json(json.dumps(rows))

    @line_cell_magic
    def stackql(self, line, cell=None):
        if cell is None:
            results = self.run_query(self.get_rendered_query(line))
        else:
            results = self.run_query(self.get_rendered_query(cell))
        return results            

def load_ipython_extension(ipython):
    """
    Any module file that define a function named `load_ipython_extension`
    can be loaded via `%load_ext module.path` or be configured to be
    autoloaded by IPython at startup time.
    """
    ipython.register_magics(StackqlMagic)

