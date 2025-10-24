import sys, random, math, bisect, heapq, threading
from heapq import heappush, heappop, heapify
from collections import defaultdict, deque, Counter
from itertools import combinations, permutations
mod = 10**9 + 7
R = random.randint(1, 2**31)  # dic[ i ^ R] # c = Counter(x ^ R for x in a)

DIRECTIONS_4 = [(-1, 0), (1, 0), (0, -1), (0, 1)]
DIRECTIONS_8 = [(-1, -1), (-1, 1), (1, -1), (1, 1), (-1, 0), (1, 0), (0, -1), (0, 1)]

def dir8(x, y): return [(x, y), (x, -y), (-x, y), (-x, -y), (y, x), (y, -x), (-y, x), (-y, -x)]
def dir4(x, y): return [(x, y), (x, -y), (-x, y), (-x, -y)]
def iinp(): return int(sys.stdin.readline())
def sinp(): return sys.stdin.readline().strip()
def linp(): return [int(i) for i in sys.stdin.readline().strip().split()]
def lcm(x, y): return x * y // math.gcd(x, y)
def ceil_div(x, y): return (x + y - 1) // y
def bin_search(arr, x): return bisect.bisect_left(arr, x)
def debug(*args): print("DEBUG:", *args, file=sys.stderr)
def inbound(x, y, n, m): return 0 <= x < n and 0 <= y < m

def solve():
    

t = 1
t = iinp()
for _ in range(t):
    solve()