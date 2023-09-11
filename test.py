# get iam bindings asynchronously
import nest_asyncio, json
nest_asyncio.apply()
from pystackql import StackQL
import pandas as pd

stackql = StackQL()

stackql.executeStmt('REGISTRY PULL google')

projects = []

queries = [
    f"""
    SELECT role, condition, members, '{project}' as project
    FROM google.cloudresourcemanager.projects_iam_policies
    WHERE projectsId = '{project}'
    """
    for project in projects
]

res = stackql.executeQueriesAsync(queries)
bindings_df = pd.read_json(json.dumps(res))
print(bindings_df)