module Folding(foldTree) where

import Data
import DataUtil

foldTree :: Tree Conf -> Graph Conf
foldTree t = fixTree (tieKnot []) t

-- we tie a knot only for calls
-- it is enough in the first-order settings
tieKnot :: [Node Conf] -> Node Conf -> Tree Conf -> Graph Conf
tieKnot ns n t@(Node e _) =
	case [(k, r) | k <- n:ns, isCall e, Just r <- [renaming (expr k) e]] of
		[] -> fixTree (tieKnot (n:ns)) t
		(k, r):_ -> Node e (Fold k r)

fixTree :: (Node t -> Tree t -> Graph t) -> Tree t -> Graph t
fixTree f (Node e (Transient c)) = t where
	t = Node e $ Transient $ f t c
fixTree f (Node e (Decompose cs)) = t where 
	t = Node e $ Decompose [f t c | c <- cs]
fixTree f (Node e (Variants cs)) = t where
	t = Node e $ Variants [(p, f t c) | (p, c) <- cs]
fixTree f (Node e Stop) = (Node e Stop)