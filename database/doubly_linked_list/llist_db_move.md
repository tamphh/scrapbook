I wrote this a long time ago as a proof-of-concept for a vaporware project. Recently I have had the need to something which seems easy at a high-level standpoint, but is actually quite hard to implement.

The original purpose for this concept was to easily maintain a strict order of data held within the rows, while still having the option to reorder the rows in an efficient manner (one table, no joins, no special embedded scripts etc).

A little insight into what I was doing: I once worked on a network security team for a tier-1 ISP. A coworker and myself had already written some really nice code to deal with the thousands (yes, thousands) of firewalls we dealt with on a daily basis. We created an API which generated abstracted structures of firewall configurations; by abstracting I mean creating a singular data-structure which represented rules, and rule-sets (a nice side-effect of this method was we could morph one firewall syntax structure to another. E.g., juniper filters -> netscreen rules. Needless to say we spent a great deal of time writing EBNF, but I digress. 

My co-worker and I had a longing (or should I say, pipe dream) to create database abstractions around this. It was hard, lots of discussions, but we just didn't have the time. One of the pitfalls was the aforementioned ordering. Sometimes a firewall rule would have to be moved up or down in a single database; not something that can be accomplished efficiently or atomically. 

The most efficient way of creating a strict order of data which where data can still be moved is to use a simple doubly linked-list. But in SQL, this is easier said than done. But the following snippet I found laying around still seems pretty damned cool to me. So I'm sharing it with all.

```python
#!/usr/bin/python
import psycopg
import sys
from copy import copy, deepcopy
from pprint import pprint

"""
start out with this data:
CREATE TABLE list (
    rule BIGINT,
    prev BIGINT,
    next BIGINT
);

INSERT INTO list (rule, prev, next) VALUES (1, -1, 2);
INSERT INTO list (rule, prev, next) VALUES (2, 1, 3);
INSERT INTO list (rule, prev, next) VALUES (3, 2, 4);
INSERT INTO list (rule, prev, next) VALUES (4, 3, 5);
INSERT INTO list (rule, prev, next) VALUES (5, 4, -1);
"""

o = psycopg.connect('dbname=test user=ellzey')
c = o.cursor()

def fetch_nodes(cursor):
    nodehash = dict()
    root     = None
    
    cursor.execute("SELECT rule, prev, next FROM list") 
    nodes = c.dictfetchall()

    for node in nodes:

        if node['prev'] == -1:
            root = node

        nodehash[node['rule']] = node
    
    return root, nodehash

def print_nodes(root, nodes):
    # start off with the 
    next = root['rule']

    while next > 0:
        print next
        next = nodes[next]['next']

def move_node(db, nodes, x, y):
    # move node x before y


    x = nodes[x]
    y = nodes[y]

    if y['prev'] == x['rule']:
        return 
    
    c = db.cursor()
    c.execute("UPDATE list SET next=%d WHERE rule=%d" % (x['next'], x['prev']))
    c.execute("UPDATE list SET prev=%d WHERE rule=%d" % (x['prev'], x['next']))
    c.execute("UPDATE list SET next=%d WHERE rule=%d" % (y['rule'], x['rule']))
    c.execute("UPDATE list SET prev=%d WHERE rule=%d" % (y['prev'], x['rule']))
    c.execute("UPDATE list SET next=%d WHERE rule=%d" % (x['rule'], y['prev']))
    c.execute("UPDATE list SET prev=%d WHERE rule=%d" % (x['rule'], y['rule']))
    db.commit()

root, nodehash = fetch_nodes(c)
print "BEFORE MOVE"
print_nodes(root, nodehash)

move_node(o, nodehash, int(sys.argv[1]), int(sys.argv[2]))

print "AFTER MOVE"
root, nodehash = fetch_nodes(c)
print_nodes(root, nodehash)
```
