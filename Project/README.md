Group Project was made by: 
Oleksandr Aleshchenko - up202210478 (48%) :
- travelSales implmenetation
- shortestPath implementation
- README file
Hugo Cruz - up202205022 (52%):
- basic functions implementation (functions 1 through 7)
- shortestPath implementation

### `shortestPath` Function

The `shortestPath` function finds the shortest path between two cities in a road map, using Dijkstra's algorithm to compute the minimum distance.
#### **Algorithm**:

- **Dijkstra’s Algorithm** is used because it efficiently finds the shortest path in a graph with positive edge weights. It is particularly suitable for this case, as each city in the roadmap has a non-negative distance to its neighbors.
- Dijkstra’s algorithm relies on a priority queue to process paths in order of increasing distance from the start, ensuring that the shortest path to each city is found.
#### **Algorithm Steps**:

- The `shortestPath` function initializes the queue with the starting city at distance zero.
- The `dijkstra` helper function performs the following:
    - Pops the city with the smallest distance from the queue.
    - If the popped city matches the `end` city, the path to this city is returned.
    - If the city has already been visited, it is skipped.
    - Otherwise, each of the city’s neighbors is checked, and unvisited neighbors are added to the queue with their updated distances.
- The queue is then re-sorted by distance, prioritizing paths with shorter distances.
#### **Edge Cases**:

- If `start` and `end` are the same, the function immediately returns a path containing just the city itself.
- If no path is found by the time the queue is empty, an empty list is returned.

- **Queue Management**:
    
    - Sorting the queue after each addition simulates a priority queue. Sorting has a time complexity of O(log⁡k)O(\log k)O(logk), where kkk is the current length of the queue. In the worst case, kkk grows linearly with the number of cities nnn.
- **Graph Traversal**:
    
    - For each city, we examine its neighbors and update paths. Since there are mmm edges, each examined once, the traversal complexity is O(m)O(m)O(m).
- **Overall Complexity**:
    
    - With the use of a simple list for queue management (sorted after each update), the complexity is O(n2log⁡n+m)O(n^2 \log n + m)O(n2logn+m) in the worst case.
    - Using a more efficient priority queue, such as a Fibonacci heap, would improve it to O((n+m)log⁡n)O((n + m) \log n)O((n+m)logn).

### `travelSales` Function

The `travelSales` function implements a solution for the Traveling Salesman Problem (TSP) on the roadmap, returning a path that visits all cities once and returns to the starting city.
#### **Algorithm Choice**:

- **Dynamic Programming with Bitmasking** (DP + Bitmasking) is used for an optimized TSP solution. This approach reduces the exponential complexity of the brute-force solution to `O(n^2 * 2^n)`, where `n` is the number of cities.
- The DP solution is suitable for road maps with a reasonable number of cities and leverages the power of precomputed shortest paths between cities.

#### 2. **Data Structures**:

- **Precomputed Distances**: Using the `shortestPath` function, all pairwise shortest paths between cities are precomputed and stored in an array, `precomputedDistances`. This ensures that distance calculations are available in constant time during the DP stage, reducing overall complexity.
- **Memoization Table (`memoArray`)**: A two-dimensional array is used to store results for subproblems, avoiding redundant calculations and ensuring that each state is computed only once. The keys of the memoization array are pairs `(visited, lastCity)`, representing the cities visited so far and the current city.
- **Bitmasking**: A bitmask represents the set of cities that have been visited. Each bit in an integer corresponds to a city, with a value of 1 indicating that the city has been visited. This allows efficient storage and manipulation of the `visited` set.

The `travelSales` function addresses the Traveling Salesman Problem (TSP) using Dynamic Programming with Bitmasking. This approach leverages memoization and shortest path precomputation to optimize performance.

1. **Shortest Path Precomputation**:
    
    - For each pair of cities, we run `shortestPath` to calculate the minimum distance. Since `shortestPath` runs in O((n+m)log⁡n)O((n + m) \log n)O((n+m)logn) and we call it for all pairs of cities, the precomputation has a total complexity of O(n2⋅(n+m)log⁡n)O(n^2 \cdot (n + m) \log n)O(n2⋅(n+m)logn).
2. **Dynamic Programming with Bitmasking**:
    
    - **States**: There are 2n2^n2n subsets of cities, and for each subset, we track the last visited city, giving O(n⋅2n)O(n \cdot 2^n)O(n⋅2n) states.
    - **Transitions**: For each state, we consider transitions to any unvisited city, requiring O(n)O(n)O(n) operations. Therefore, the DP part has a complexity of O(n2⋅2n)O(n^2 \cdot 2^n)O(n2⋅2n).
3. **Overall Complexity**:
    
    - The total complexity for `travelSales` combines the precomputation and the DP stages:
        - **Shortest Path Precomputation**: O(n2⋅(n+m)log⁡n)O(n^2 \cdot (n + m) \log n)O(n2⋅(n+m)logn)
        - **DP with Bitmasking**: O(n2⋅2n)O(n^2 \cdot 2^n)O(n2⋅2n)

Thus, the **overall time complexity of `travelSales` is O(n2⋅(n+m)log⁡n+n2⋅2n)O(n^2 \cdot (n + m) \log n + n^2 \cdot 2^n)O(n2⋅(n+m)logn+n2⋅2n)**.
