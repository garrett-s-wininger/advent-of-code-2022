import Data.Char
import System.Environment
import System.IO

scoreTree :: [Int] -> Int -> Int -> Int -> Int -> Int
scoreTree grid width height posX posY
    -- Prevent out of bounds access
  | (posX < 0 || posX >= width) =
    error "X position must be positive and within grid"
  | (posY < 0 || posY >= height) =
    error "Y position must be positive and within grid"
    -- Outside of grid is always viewable
  | posX == 0 = 1
  | posX == (width - 1) = 1
  | posY == 0 = 1
  | posY == (height - 1) = 1
    -- Internal trees need to validate each direction
  | all
     (\adjacentTreeHeight -> adjacentTreeHeight < currentTreeHeight)
     (map (\offset -> (grid !! offset)) northTrees) = 1
  | all
     (\adjacentTreeHeight -> adjacentTreeHeight < currentTreeHeight)
     (map (\offset -> (grid !! offset)) eastTrees) = 1
  | all
     (\adjacentTreeHeight -> adjacentTreeHeight < currentTreeHeight)
     (map (\offset -> (grid !! offset)) southTrees) = 1
  | all
     (\adjacentTreeHeight -> adjacentTreeHeight < currentTreeHeight)
     (map (\offset -> (grid !! offset)) westTrees) = 1
  | otherwise = 0
  where
    currentTreeHeight = grid !! (posX + (width * posY))
    northTrees = [posX + (width * (posY - x)) | x <- [1 .. posY]]
    eastTrees = [(posX + x) + (width * posY) | x <- [1 .. (width - posX - 1)]]
    southTrees = [posX + (width * (posY + x)) | x <- [1 .. (height - posY - 1)]]
    westTrees = [(posX - x) + (width * posY) | x <- [1 .. posX]]

scoreForest :: [Int] -> Int -> Int -> [Int]
scoreForest grid width height =
  map
    (\coords -> scoreTree grid width height (fst coords) (snd coords))
    [(x, y) | x <- [0 .. (width - 1)], y <- [0 .. (height - 1)]]

main = do
  args <- getArgs
  if (length args) /= 1
    then error "Usage: main <filepath>"
    else do
      contents <- readFile $ head args
      let ordLines = [[ord y - 48 | y <- x] | x <- words contents]
      putStrLn $
        show $
        sum $
        scoreForest (concat ordLines) (length $ head ordLines) (length ordLines)
