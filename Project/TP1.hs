import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]


cities :: RoadMap -> [City] -- Returns a list with all the cities referenced in a RoadMap 
cities mapX = Data.List.nub (allCities mapX)

allCities :: RoadMap -> [City] -- Returns a list with all the cities referenced in a RoadMap (with duplicates)
allCities [] = []
allCities ((city1,city2,d):xs) = city1 : city2 : allCities xs


areAdjacent :: RoadMap -> City -> City -> Bool -- Checks if two cities of a RoadMap are adjacent 
areAdjacent [] _ _= False                      -- returning True if they are, and False otherwise 
areAdjacent ((cityX, cityY, d):xs) city1 city2 = 
    ((city1 == cityX && city2 == cityY ) || city1 == cityY && city2 == cityX) || areAdjacent xs city1 city2


distance :: RoadMap -> City -> City -> Maybe Distance                       -- Returns the distance between two cities if
distance mapX city1 city2 | not (areAdjacent mapX city1 city2) = Nothing    -- they are connected and Nothing otherwise
distance ((cityX, cityY, d):xs) city1 city2
    |(city1 == cityX && city2 == cityY ) || city1 == cityY && city2 == cityX = Just d
    |otherwise = distance xs city1 city2


adjacent :: RoadMap -> City -> [(City,Distance)]        -- Returns a list of cities adjacent to the given city,
adjacent [] _ =[]                                       --  along with the respective distances between them
adjacent ((cityX, cityY, d):xs) city1
    | cityX == city1 = (cityY, d) : adjacent xs city1
    | cityY == city1 = (cityX, d) : adjacent xs city1
    | otherwise = adjacent xs city1
adjacentCity :: RoadMap -> City -> [City]
adjacentCity [] _ =[]
adjacentCity ((cityX, cityY, d):xs) city1
    | cityX == city1 = cityY : adjacentCity xs city1
    | cityY == city1 = cityX : adjacentCity xs city1
    | otherwise = adjacentCity xs city1


pathDistance :: RoadMap -> Path -> Maybe Distance  -- Given a list of cities (Path), returns the total distance if all cities in the path are adjacent.
pathDistance _ [] = Just 0                         -- Returns Nothing if any two consecutive cities in the path are not directly connected.                         
pathDistance _ [x] = Just 0
pathDistance mapX (x:y:xs)=
    case distance mapX x y of
        Nothing -> Nothing
        Just d -> case pathDistance mapX (y:xs) of
            Nothing -> Nothing
            Just remainingDistance -> Just (d + remainingDistance)


rome :: RoadMap -> [City]   -- returns a list with the cities that have the maximum number of direct connections 
rome mapX =
    let cityList = cities mapX
        connectionList = listAllConnections cityList mapX
        maxConnections = maximum [connection | (_ , connection)<-connectionList]
    in [city |(city, connection)<-connectionList, connection == maxConnections ]

countConnections :: City -> RoadMap -> Int   --counts the number ofCities adjacent to a given city
countConnections _ [] = 0
countConnections cityX ((city1, city2, d):xs)
    |cityX == city1 || cityX == city2 = 1+ countConnections cityX xs
    |otherwise = countConnections cityX xs

listAllConnections :: [City] -> RoadMap -> [(City, Int)] -- Returns a list of pairs, where each pair    
listAllConnections _ [] = []                             -- contains a city and its number of direct connections in the roadmap     
listAllConnections [] _ = []
listAllConnections (cityX:xs) mapX = (cityX,countConnections cityX mapX) : listAllConnections xs mapX


isStronglyConnected :: RoadMap -> Bool  --Checks if a RoadMap is stringly connected by performing a DFS in each direction
isStronglyConnected mapX=               -- 
    case cities mapX of
        [] -> True
        (starCity:_) -> isConneted starCity mapX && isConneted starCity (reverseGraph mapX)

reverseGraph:: RoadMap -> RoadMap   -- returns a RoadMap with the direction of the connections reversed 
reverseGraph [] = []
reverseGraph ((city1, city2, d):xs) = (city2, city1, d) : reverseGraph xs

dfsVisit:: City -> RoadMap -> [City] -> [City] -- performs a Depth First Searh in the RoadMap (graph) starting from a given city
dfsVisit currentCity mapX visited              -- returns a list with the cities visited
    | null (adjacentCity mapX currentCity) = []
    | currentCity `elem` visited = visited
    | otherwise = foldl (\vis neighbor -> dfsVisit neighbor mapX vis) (currentCity : visited) (adjacentCity mapX currentCity)

isConneted:: City-> RoadMap -> Bool -- Checks if a graph is "one way" connected by performing a DFS in the RoadMap
isConneted starCity mapX=           -- and comparing the length of the visited cities list and  the list with all the cities in the RoadMap
    let allCities = cities mapX
        visited = dfsVisit starCity mapX []
    in length visited == length allCities

type QueueItem = (Distance, Path)  -- (Distance from start, Path to the current city)

-- The shortestPath function
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath mapX start end
    | start == end = [[start]]  -- If start and end are the same, the shortest path is just the city itself
    | otherwise = dijkstra mapX [(0, [start])] [] end  -- Start with the initial queue

-- Helper function implementing Dijkstra's algorithm
dijkstra :: RoadMap -> [QueueItem] -> [City] -> City -> [Path]
dijkstra _ [] _ _ = []  -- If the queue is empty, no path was found
dijkstra mapX ((dist, path):queue) visited end
    | currentCity == end = [path]  -- If we reached the destination, return the path
    | currentCity `elem` visited = dijkstra mapX queue visited end  -- Skip if already visited
    | otherwise =
        let
            -- Mark the current city as visited
            newVisited = currentCity : visited
            -- Expand neighbors not yet visited
            neighbors = adjacent mapX currentCity
            newQueueItems = [(dist + d, path ++ [neighbor]) | (neighbor, d) <- neighbors, neighbor `notElem` visited]
            -- Combine and sort the new queue to simulate priority queue behavior (smallest distance first)
            newQueue = Data.List.sortBy (\(d1, _) (d2, _) -> compare d1 d2) (queue ++ newQueueItems)
        in
            dijkstra mapX newQueue newVisited end
  where
    currentCity = last path  -- Get the current city from the path

-- Add the missing definition of getDistance
getDistance :: RoadMap -> City -> City -> Distance
getDistance mapX city1 city2 = case distance mapX city1 city2 of
    Just d -> d
    Nothing -> maxBound -- maxBound represents "infinity" for unconnected cities

-- Solves the Traveling Salesman Problem using dynamic programming and memoization
travelSales :: RoadMap -> Path
travelSales mapX
    | not (isStronglyConnected mapX) = []  -- If the map is not strongly connected, return an empty list
    | otherwise = let
        -- Step 1: Create a list of all cities and assign each city an index
        allCitiesList = cities mapX
        n = length allCitiesList
        cityIndexMap = zip allCitiesList [0..]  -- Mapping cities to indices
        indexCityMap = map (\(city, idx) -> (idx, city)) cityIndexMap  -- Map indices back to cities

        -- Convert a city name to its assigned index
        cityToIndex city = case lookup city cityIndexMap of
            Just idx -> idx
            Nothing -> error "City not found in index map"

        -- Convert an index to its city name
        indexToCity idx = case lookup idx indexCityMap of
            Just city -> city
            Nothing -> error "Index not found in city map"

        -- Step 2: Initialize memoization table
        -- Memo array for storing minimum distances: memo[visited][lastCity]
        memo = Data.Array.array ((0, 0), (2^n - 1, n - 1)) [((s, i), -1) | s <- [0..2^n - 1], i <- [0..n - 1]]

        -- Recursive function to calculate minimum distance using DP
        tspDP :: Int -> Int -> Distance
        tspDP visited lastCity
            | visited == (1 `Data.Bits.shiftL` n) - 1 = getDistance mapX (indexToCity lastCity) (indexToCity 0) -- Return to start
            | memo Data.Array.! (visited, lastCity) /= -1 = memo Data.Array.! (visited, lastCity) -- Memoized result
            | otherwise = let
                -- Find minimum distance by visiting unvisited cities
                result = minimum [getDistance mapX (indexToCity lastCity) (indexToCity nextCity) +
                                  tspDP (visited `Data.Bits.setBit` nextCity) nextCity |
                                  nextCity <- [0..n - 1], not (visited `Data.Bits.testBit` nextCity)]
                in result

        -- Reconstruct the path after finding the optimal tour
        reconstructPath :: Int -> Int -> [Int]
        reconstructPath visited lastCity
            | visited == (1 `Data.Bits.shiftL` n) - 1 = [lastCity]  -- All cities visited, return to start
            | otherwise = lastCity : let
                -- Find the next city that minimizes travel distance
                nextCity = Data.List.minimumBy (\next1 next2 ->
                    compare (getDistance mapX (indexToCity lastCity) (indexToCity next1) +
                            tspDP (visited `Data.Bits.setBit` next1) next1)
                            (getDistance mapX (indexToCity lastCity) (indexToCity next2) +
                            tspDP (visited `Data.Bits.setBit` next2) next2))
                        [c | c <- [0..n - 1], not (visited `Data.Bits.testBit` c)]
                in reconstructPath (visited `Data.Bits.setBit` nextCity) nextCity

        -- Find the optimal path starting from city index 0
        startCityIdx = 0
        optimalPathIndices = reconstructPath (1 `Data.Bits.setBit` startCityIdx) startCityIdx
        optimalPath = map indexToCity optimalPathIndices
    in optimalPath ++ [indexToCity startCityIdx] -- Return to the starting city

tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]