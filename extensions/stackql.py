from __future__ import print_function
import pandas as pd
import psycopg2, json, argparse
from psycopg2.extras import RealDictCursor
from IPython.core.magic import (Magics, magics_class, line_cell_magic)
from io import StringIO
from string import Template

# Make sure to use your own database connection details here.
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
        json_str = json.dumps(rows)
        return pd.read_json(StringIO(json_str))

    @line_cell_magic
    def stackql(self, line, cell=None):
        is_cell_magic = cell is not None  # Check if it's cell magic

        if is_cell_magic:
            parser = argparse.ArgumentParser()
            parser.add_argument("--no-display", action="store_true", help="Do not display the result.")
            args = parser.parse_args(line.split())
            query_to_run = self.get_rendered_query(cell)  # If cell magic, the query comes from the cell content
        else:
            args = None  # No arguments for line magic
            query_to_run = self.get_rendered_query(line)  # If line magic, the query comes from the line itself

        results = self.run_query(query_to_run)  # Run the query
        self.shell.user_ns['stackql_df'] = results  # Store the results as a DataFrame in the user namespace

        # Conditionally display the results
        if is_cell_magic and args and not args.no_display:
            return results
        elif not is_cell_magic:
            return results

def load_ipython_extension(ipython):
    """
    Any module file that defines a function named `load_ipython_extension`
    can be loaded via `%load_ext module.path` or be configured to be
    autoloaded by IPython at startup time.
    """
    ipython.register_magics(StackqlMagic)
