"""
This module provides IPython magic for querying a StackQL database.

The primary functionality is exposed through the `stackql` cell magic
which allows querying the database and returning the results as a Pandas DataFrame.

Attributes:
    conn (psycopg2.extensions.connection): Connection to the StackQL database.

Classes:
    StackqlMagic: Defines the `stackql` cell magic.

Functions:
    load_ipython_extension(ipython): Register the magic with IPython.
"""

import pandas as pd
import psycopg2
import json
from psycopg2.extras import RealDictCursor
from IPython.core.magic import (Magics, magics_class, cell_magic)
from string import Template
import argparse

conn = psycopg2.connect("dbname=stackql user=stackql host=localhost port=5444")

@magics_class
class StackqlMagic(Magics):
    """
    Defines the `stackql` cell magic.
    
    This class provides an IPython cell magic, `stackql`, which allows querying
    a StackQL database and returning the results as a Pandas DataFrame.
    
    The magic also supports argument parsing to control its behavior:
    - `--no-display`: If specified, the results won't be displayed.
    """
    
    @cell_magic
    def stackql(self, line, cell=None):
        """
        The `stackql` cell magic queries the StackQL database using the provided SQL
        in the cell. The results are returned as a Pandas DataFrame and 
        optionally displayed based on the arguments.
        
        Args:
            line (str): The arguments for the magic.
            cell (str, optional): The SQL query to run.
        
        Returns:
            pd.DataFrame: The results of the query, if `--no-display` is not specified.
        """
        parser = argparse.ArgumentParser()
        parser.add_argument("--no-display", action="store_true", help="Do not display the result.")
        args = parser.parse_args(line.split())
        
        # Fetch args_json from the environment
        arguments = json.loads(self.shell.user_ns.get("args_json", "{}"))
        
        # Substitute the arguments into the query
        rendered_query = Template(cell).substitute(arguments)

        results = self.run_query(rendered_query)
        
        # Assigning results to a variable in the global namespace
        self.shell.user_ns['stackql_df'] = results
        
        # Conditionally display results
        if not args.no_display:
            return results
    
    def run_query(self, query):
        """
        Executes the given SQL query against the StackQL database.
        
        Args:
            query (str): The SQL query to execute.
        
        Returns:
            pd.DataFrame: The results of the query as a DataFrame.
        """
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(query)
            rows = cur.fetchall()
            return pd.read_json(json.dumps(rows))

def load_ipython_extension(ipython):
    """
    Registers the `StackqlMagic` class with IPython.
    
    This function is automatically called by IPython when using 
    `%load_ext ext.stackql`.
    
    Args:
        ipython (InteractiveShell): The IPython shell instance.
    """
    ipython.register_magics(StackqlMagic)
