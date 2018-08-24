
# Query access methods
1. USE KEYS -> Document fetch, no index scan (Fastest)
2. COVERED INDEX -> Query is processed with index scan only. 
3. Index Scan -> Partial index scan, then fetches
4. JOIN -> Fetch of left-hand side, then fetched of right-hand side
5. Primary Scan -> Full bucket scan, then fetches

# Indexing options
1. Primary index (Index on the doc key on the whole bucket)
2. Named primary index (Give name for the primary index. Allows multiple indexes in the cluster)
3. Secondary index (Index on tthe key-value or doc key)
4. Secondary composite index (Index on more than one key-value)
5. Functional index (Index on function or expression on key-values)
6. Array index (Index individual elements of the array)
7. Partial index (Index subset of items in the bucket)
8. Covering index 
9. Duplicate index (Not a type of index. Feature of indexing that allows load balancing. Thus providing scale-out, MDS, performance, and HA)
