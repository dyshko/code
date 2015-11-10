#DEFINITIONS

import itertools
import copy

# This function returns a partition into orbits
# of an element g of a group G.
# Orbits are subsets of a vector space V.
def orbitsOfGroupElement(g, V, G):
    t = list(V)
    #initiating the resulting partition
    partition = []
    while len(t)>0:
        orbit = []
        #running through a cyclic subgroup generated by g
        for h in G.subgroup([g]):
            x = t[0]*h
            if not x in orbit:
                orbit.append(x)
        orbit.sort()
        partition.append(orbit)
        for v in orbit:
            t.remove(v)
    partition.sort()
    return partition

#removes duplicates from a (nonhashable) tuple
def removeDuplicates(a):
    b=[]
    for x in a:
        if x not in b:
            b.append(x)
    return b

# unite two orbits in a partition
def uniteTwoOrbits(partition, orbit1, orbit2):
    i=partition.index(orbit1)
    j=partition.index(orbit2)
    if i!=j:
        partition[i]=list(removeDuplicates(orbit1 + orbit2))
        del partition[j]

# returns an orbit that contains the given element x
def find(partition,x):
    for orbit in partition:
        if x in orbit:
            return orbit

#merges two partition into orbits
def mergePartitions(partition1, partition2):
    partition3 = copy.deepcopy(partition1)
    for orbit in partition2:
        for i in range(len(orbit)-1):
            uniteTwoOrbits(partition3,\
                find(partition3,orbit[i]),\
                find(partition3,orbit[i+1]))
    return partition3

#returns True if g preserves the orbits of orbs
def fixes(g, partition):
    for orbit in partition:
        for x in orbit:
            if x*g not in orbit:
               return False
    return True

#returns a closed group with the gives set of orbits
def makeClosure(partition, G):
    group = []
    for g in G:
        if fixes(g, partition):
            group.append(g)
    return group

#checks if two elements are in same orbit
def inSameOrbit(x,y,partition):
    for orbit in partition:
        if x in orbit and y in orbit:
            return True
    return False

#check if the map f extends to an element of the group
def isExtendable(x,fx,y,fy,group):
    for g in group:
        if x*g == fx and y*g == fy:
            return [g,True]
    return [0,False]


#MAIN PROGRAM

print("Initializing...")
#the dimension of the space
n=3
#the size of the finite field
q=2
#declaration of the finite field
F=GF(q)
#n by n invertible matrices over the finite field F
G=GL(n,F)
#space of n by n matrices over the finite field F
M=MatrixSpace(F,n,n)
#vector space F^n
V=VectorSpace(F,n)
#declaring two elements of the vector space a = (1,0,0)
#and b = (0,1,0)
a=V([1,0,0])
b=V([0,1,0])

print("Initialization of basic objects is finished\n"+
"Building partitions into orbits for cyclic groups...")

#Creating a dictionary of orbit partitions for quick access
P=dict()
for g in G:
    if a*g==a:
        orb=orbitsOfGroupElement(g,V,G)
        P[str(orb)]=orb

print("There are "+str(len(P))+
" different partitions into orbits for cyclic groups.\n"+
"Developing partitions into orbits...")

#calculating all possible orbits
flag=True
checked=[]
while(flag):
    flag=False
    t=dict()
    for key1,key2 in itertools.combinations(P,r=2):
        if not [key1,key2] in checked:
            partition3=mergePartitions(P[key1],P[key2])
            checked.append([key1,key2])
            for orb in partition3:
                orb.sort()
            partition3.sort()
            key3=str(partition3)
            if key3 not in P:
                t[key3]=partition3
                flag=True
    for key in t:
        P[key]=t[key]

print("There are "+str(len(P))+
" different partitions into orbits\nBuilding groups...")

#Now we start to build closed group for each orbit
setOfClosedGroups=[]
for key in P:
    setOfClosedGroups.append([P[key],\
        makeClosure(P[key],G)])

print("All groups are built.\nChecking each group...")

exampleFound = False
for partition, group in setOfClosedGroups:
    for c in V:
        if inSameOrbit(b,c,partition) and\
            inSameOrbit(a+b,a+c,partition):
                g, ans=isExtendable(a,a,b,c,group)
                if not ans:
                    print(c,g)
                    exampleFound = True
                    break
if not exampleFound:
    print("No counterexample found.")

print("The program finished.")