import qualified Data.List
--import qualified Data.Array
--import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]
--sampleRoadMap = [("Porto", "Lisboa", 300), ("Porto", "Braga", 50), ("Lisboa", "Faro", 280), ("Braga", "Coimbra", 120), ("Coimbra", "Lisboa", 200)]

cities :: RoadMap -> [City]
cities mapX = Data.List.nub (allCities mapX)

allCities :: RoadMap -> [City] -- Returns a list with all the cities referenced in a RoadMap (with duplicates)
allCities [] = []
allCities ((city1,city2,d):xs) = city1 : city2 : allCities xs


areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent [] _ _= False
areAdjacent ((cityX, cityY, d):xs) city1 city2 = ((city1 == cityX && city2 == cityY ) || city1 == cityY && city2 == cityX) || areAdjacent xs city1 city2


distance :: RoadMap -> City -> City -> Maybe Distance
distance mapX city1 city2 | not (areAdjacent mapX city1 city2) = Nothing
distance ((cityX, cityY, d):xs) city1 city2
    |(city1 == cityX && city2 == cityY ) || city1 == cityY && city2 == cityX = Just d
    |otherwise = distance xs city1 city2


adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ =[]
adjacent ((cityX, cityY, d):xs) city1
    | cityX == city1 = (cityY, d) : adjacent xs city1
    | cityY == city1 = (cityX, d) : adjacent xs city1
    | otherwise = adjacent xs city1 


pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance = undefined

rome :: RoadMap -> [City]
rome = undefined

isStronglyConnected :: RoadMap -> Bool
isStronglyConnected = undefined

shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath = undefined

travelSales :: RoadMap -> Path
travelSales = undefined

tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]


