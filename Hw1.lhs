---
title: Homework #1, Due Friday, January 20th
---

Preliminaries
-------------

Before starting this assignment:

1. Read chapters 1 -- 3 of The Haskell School of Expression.
2. Download and install the [Glasgow Haskell Compiler (GHC)](http://www.haskell.org/ghc/).
3. Download the SOE code bundle from
   [the Haskell School of Expression page](/static/SOE.tar.gz).
4. Verify that it works by changing into the `SOE/src` directory and
   running `ghci Draw.lhs`, then typing `main0` at the prompt:
 
~~~
cd SOE/src
ghci Draw.lhs
*Draw> main0
~~~

  You should see a window with some shapes in it.

**NOTE:** If you have trouble installing SOE, [see this page](soe-instructions.html)

5. Download the required files for this assignment: [hw1.tar.gz](/static/hw1.tar.gz).
   Unpack the files and make sure that you can successfully run the main program (in `Main.hs`).
   We've provided a `Makefile`, which you can use if you like. You should see this output:

~~~
Main: Define me!
~~~

Haskell Formalities
-------------------

We declare that this is the Hw1 module and import some libraries:

> module Hw1 where
> import SOE
> import Play
> import XMLTypes

> myName = "Jian Xu"
> myEmail = "jix024@cs.ucsd.edu"
> mySID = "A53026658"


Part 1: Defining and Manipulating Shapes
----------------------------------------

You will write all of your code in the `hw1.lhs` file, in the spaces
indicated. Do not alter the type annotations --- your code must
typecheck with these types to be accepted.

The following are the definitions of shapes from Chapter 2 of SOE:

> data Shape = Rectangle Side Side
>            | Ellipse Radius Radius
>            | RtTriangle Side Side
>            | Polygon [Vertex]
>            deriving Show
 
> type Radius = Float 
> type Side   = Float
> type Vertex = (Float, Float)

1. Below, define functions `rectangle` and `rtTriangle` as suggested
   at the end of Section 2.1 (Exercise 2.1). Each should return a Shape
   built with the Polygon constructor.

> rectangle :: Side -> Side -> Shape
> rectangle side1 side2 = Polygon[(0.0, 0.0), (0.0, side2), (side1, side2), (side1, 0.0)] 

> rtTriangle :: Side -> Side -> Shape
> rtTriangle side1 side2 = Polygon[(0.0, 0.0), (0.0, side2), (side1, 0.0)] 

2. Define a function

> sides :: Shape -> Int
> sides (Rectangle s1 s2) = 4
> sides (RtTriangle s1 s2) = 3
> sides (Ellipse r1 r2) = 42
> sides (Polygon []) = 0
> sides (Polygon [_]) = 0
> sides (Polygon [_, _]) = 0
> sides (Polygon [_, _, _]) = 3
> sides (Polygon (v:vs)) = 1 + sides (Polygon (vs))

  which returns the number of sides a given shape has.
  For the purposes of this exercise, an ellipse has 42 sides,
  and empty polygons, single points, and lines have zero sides.

3. Define a function

> biggerPoint :: Float -> Vertex -> Vertex
> biggerPoint e (f1, f2) = ((f1 * sqrt(e)), (f2 * sqrt(e)))
> bigger :: Shape -> Float -> Shape
> bigger (Rectangle s1 s2) e = Rectangle (s1 * sqrt(e)) (s2 * sqrt(e))
> bigger (RtTriangle s1 s2) e = RtTriangle (s1 * sqrt(e)) (s2 * sqrt(e))
> bigger (Ellipse r1 r2) e = Ellipse (r1 * sqrt(e)) (r2 * sqrt(e))
> bigger (Polygon vs) e = Polygon (map (biggerPoint e) vs)

  that takes a shape `s` and expansion factor `e` and returns
  a shape which is the same as (i.e., similar to in the geometric sense)
  `s` but whose area is `e` times the area of `s`.

4. The Towers of Hanoi is a puzzle where you are given three pegs,
   on one of which are stacked $n$ discs in increasing order of size.
   To solve the puzzle, you must move all the discs from the starting peg
   to another by moving only one disc at a time and never stacking
   a larger disc on top of a smaller one.
   
   To move $n$ discs from peg $a$ to peg $b$ using peg $c$ as temporary storage:
   
   1. Move $n - 1$ discs from peg $a$ to peg $c$.
   2. Move the remaining disc from peg $a$ to peg $b$.
   3. Move $n - 1$ discs from peg $c$ to peg $b$.
   
   Write a function
   
> moveDisc :: String -> String -> IO ()
> moveDisc a b = putStrLn ("Move disc from " ++ a ++ " to " ++ b)

> hanoi :: Int -> String -> String -> String -> IO ()
> hanoi 0 a b c = putStr ("")
> hanoi n a b c = do
>	hanoi (n - 1) a c b
>	moveDisc a b
>	hanoi (n - 1) c b a

  that, given the number of discs $n$ and peg names $a$, $b$, and $c$,
  where a is the starting peg,
  emits the series of moves required to solve the puzzle.
  For example, running `hanoi 2 "a" "b" "c"`

  should emit the text

~~~  
move disc from a to c
move disc from a to b
move disc from c to b
~~~

Part 2: Drawing Fractals
------------------------

1. The Sierpinski Carpet is a recursive figure with a structure similar to
   the Sierpinski Triangle discussed in Chapter 3:

![Sierpinski Carpet](/static/scarpet.png)

Write a function `sierpinskiCarpet` that displays this figure on the
screen:

> fillQuad :: Window -> Int -> Int -> Int -> IO()
> fillQuad w x y size
> 	= drawInWindow w (withColor Blue
>		(polygon [(x, y), (x + size, y), (x + size, y - size), (x, y - size), (x, y)]))

> minSize :: Int
> minSize = 2
> xWin, yWin :: Int
> xWin = 400
> yWin = 400

> spaceClose :: Window -> IO ()
> spaceClose w
>   = do k <- getKey w
>        if k==' ' || k == '\x0'
>           then closeWindow w
>           else spaceClose w

> drawSierpinskiCarpet w x y size
> 	= if size <= minSize
>	  then fillQuad w x y size
>	  else let size2 = size `div` 3
>	    in do drawSierpinskiCarpet w x y size2
>	    	  drawSierpinskiCarpet w (x + size2) y size2
>	    	  drawSierpinskiCarpet w (x + size2 * 2) y size2
>	    	  drawSierpinskiCarpet w (x + size2 * 2) (y - size2) size2
>	    	  drawSierpinskiCarpet w (x + size2 * 2) (y - size2 * 2) size2
>	    	  drawSierpinskiCarpet w (x + size2) (y - size2 * 2) size2
>	    	  drawSierpinskiCarpet w x (y - size2 * 2) size2 
>	    	  drawSierpinskiCarpet w x (y - size2) size2

> sierpinskiCarpet :: IO ()
> sierpinskiCarpet
>   = runGraphics (
>     do w <- openWindow "Sierpinski Carpet" (xWin, yWin)
>        drawSierpinskiCarpet w 50 300 256
>        spaceClose w 
>     )

Note that you either need to run your program in `SOE/src` or add this
path to GHC's search path via `-i/path/to/SOE/src/`.
Also, the organization of SOE has changed a bit, so that now you use
`import SOE` instead of `import SOEGraphics`.

2. Write a function `myFractal` which draws a fractal pattern of your
   own design.  Be creative!  The only constraint is that it shows some
   pattern of recursive self-similarity.

> fillTri :: Window -> Int -> Int -> Int -> IO()
> fillTri w x y size
> 	= drawInWindow w (withColor Blue
>		(polygon [(x, y), (x + size, y), (x + size `div` 2, y - size), (x, y)]))

> drawFractal w x y size
> 	= if size <= 4
>	  then fillTri w x y size
>	  else let size2 = size `div` 2
>	    in do drawFractal w x y size2
>	    	  drawFractal w (x + size2) y size2
>	    	  drawFractal w (x + size2 `div` 2) (y - size2) size2

> myFractal :: IO ()
> myFractal
>   = runGraphics (
>     do w <- openWindow "My Fractal" (xWin, yWin)
>        drawFractal w 50 300 256
>        spaceClose w 
>     )

Part 3: Transforming XML Documents
----------------------------------

First, a warmup:

1. Read chapters 5 and 7 of SOE.

2. Do problems 5.3, 5.5, 5.6, 7.1, and 7.2 from SOE, and turn them
   is as part of the source code you create below.

   Your `maxList` and `minList` functions may assume that the lists
   they are passed contain at least one element.

> lengthNonRecrusive :: [a] -> Int
> lengthNonRecrusive xs = foldl len 0 xs
>		where len s _ = s + 1 

> doubleEach :: [Int] -> [Int]
> doubleEach [] = []
> doubleEach (x:xs) = (x * 2) : doubleEach xs

> doubleEachNonRecursive :: [Int] -> [Int]
> doubleEachNonRecursive xs = map d xs
>			where d x = x * 2

> pairAndOne :: [Int] -> [(Int, Int)]
> pairAndOne [] = []
> pairAndOne (x:xs) = (x, x + 1) : pairAndOne xs

> pairAndOneNonRecursive :: [Int] -> [(Int, Int)]
> pairAndOneNonRecursive xs = map p xs
>			where p x = (x, x + 1)

> addEachPair :: [(Int, Int)] -> [Int]
> addEachPair [] = [] 
> addEachPair (x:xs) = (fst x + snd x) : addEachPair xs

> addEachPairNonRecursive :: [(Int, Int)] -> [Int]
> addEachPairNonRecursive xs = map a xs
>			where a x = fst x + snd x 

> minList :: [Int] -> Int
> minList [] = 0
> minList [x] = x
> minList (x:xs) = if x <= minList xs
>			then x
>			else minList xs

> minListNonRecursive :: [Int] -> Int
> minListNonRecursive (x:xs) = foldl min x xs

> maxList :: [Int] -> Int
> maxList [] = 0
> maxList [x] = x
> maxList (x:xs) = if x >= maxList xs
>			then x
>			else maxList xs

> maxListNonRecursive :: [Int] -> Int
> maxListNonRecursive (x:xs) = foldl max x xs

> data Tree a = Leaf a | Branch (Tree a) (Tree a)
>               deriving (Show, Eq)

> fringe :: Tree a -> [a]
> fringe (Leaf x) = [x]
> fringe (Branch t1 t2) = fringe t1 ++ fringe t2

> treeSize :: Tree a -> Int
> treeSize (Leaf x) = 1
> treeSize (Branch t1 t2) = treeSize t1 + treeSize t2

> treeHeight :: Tree a -> Int
> treeHeight (Leaf x) = 0
> treeHeight (Branch t1 t2) = 1 + max (treeHeight t1) (treeHeight t2)

> data InternalTree a = ILeaf | IBranch a (InternalTree a) (InternalTree a)
>                       deriving (Show, Eq)

> takeTree :: Int -> InternalTree a -> InternalTree a
> takeTree n (ILeaf) = ILeaf
> takeTree n (IBranch x c1 c2) | (n > 0) = (IBranch x (takeTree (n-1) c1) (takeTree (n-1) c2))
>                              | True = (ILeaf)

takeTree n (IBranch a t1 t2) = a

> takeTreeWhile :: (a -> Bool) -> InternalTree a -> InternalTree a
> takeTreeWhile f ILeaf = ILeaf
> takeTreeWhile f (IBranch a c1 c2) | (f a) = (IBranch a (takeTreeWhile f c1) (takeTreeWhile f c2))
>                                   | True = ILeaf
 
Write the function map in terms of foldr:

> myMap :: (a -> b) -> [a] -> [b]
> myMap f [] = []
> myMap f (x:xs) = foldr (\x xs -> (f x) : xs) [] (x:xs)

The rest of this assignment involves transforming XML documents.
To keep things simple, we will not deal with the full generality of XML,
or with issues of parsing. Instead, we will represent XML documents as
instances of the following simpliﬁed type:

~~~~
data SimpleXML =
   PCDATA String
 | Element ElementName [SimpleXML]
 deriving Show

type ElementName = String
~~~~

That is, a `SimpleXML` value is either a `PCDATA` ("parsed character
data") node containing a string or else an `Element` node containing a
tag and a list of sub-nodes.

The file `Play.hs` contains a sample XML value. To avoid getting into
details of parsing actual XML concrete syntax, we'll work with just
this one value for purposes of this assignment. The XML value in
`Play.hs` has the following structure (in standard XML syntax):

~~~
<PLAY>
  <TITLE>TITLE OF THE PLAY</TITLE>
  <PERSONAE>
    <PERSONA> PERSON1 </PERSONA>
    <PERSONA> PERSON2 </PERSONA>
    ... -- MORE PERSONAE
    </PERSONAE>
  <ACT>
    <TITLE>TITLE OF FIRST ACT</TITLE>
    <SCENE>
      <TITLE>TITLE OF FIRST SCENE</TITLE>
      <SPEECH>
        <SPEAKER> PERSON1 </SPEAKER>
        <LINE>LINE1</LINE>
        <LINE>LINE2</LINE>
        ... -- MORE LINES
      </SPEECH>
      ... -- MORE SPEECHES
    </SCENE>
    ... -- MORE SCENES
  </ACT>
  ... -- MORE ACTS
</PLAY>
~~~

* `sample.html` contains a (very basic) HTML rendition of the same
  information as `Play.hs`. You may want to have a look at it in your
  favorite browser.  The HTML in `sample.html` has the following structure
  (with whitespace added for readability):
  
~~~
<html>
  <body>
    <h1>TITLE OF THE PLAY</h1>
    <h2>Dramatis Personae</h2>
    PERSON1<br/>
    PERSON2<br/>
    ...
    <h2>TITLE OF THE FIRST ACT</h2>
    <h3>TITLE OF THE FIRST SCENE</h3>
    <b>PERSON1</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
    <b>PERSON2</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
    <h3>TITLE OF THE SECOND SCENE</h3>
    <b>PERSON3</b><br/>
    LINE1<br/>
    LINE2<br/>
    ...
  </body>
</html>
~~~

You will write a function `formatPlay` that converts an XML structure
representing a play to another XML structure that, when printed,
yields the HTML speciﬁed above (but with no whitespace except what's
in the textual data in the original XML).

> processTitle :: SimpleXML -> Int -> SimpleXML
> processTitle (PCDATA s) layer = Element ("h" ++ show layer) [PCDATA s]
> processTitle (Element title (name : tail)) layer = Element ("h" ++ show layer) [name]

process PERSONAs and LINEs

> processPL :: [SimpleXML] -> [SimpleXML]
> processPL [] = []
> processPL (PCDATA a : tail) = (PCDATA a) : (Element "br" [] : processPL tail)
> processPL (Element name pl : tail) = processPL pl ++ processPL tail

> processSpeaker :: SimpleXML -> [SimpleXML]
> processSpeaker (PCDATA s) = Element "b" [PCDATA s] : [Element "br" []]
> processSpeaker (Element title (name : tail)) = 
> 		Element "b" [name] : [Element "br" []]

> processPAE :: SimpleXML -> [SimpleXML]
> processPAE (PCDATA a) = [PCDATA ""]
> processPAE (Element name tail) = Element "h2" [PCDATA "Dramatis Personae"] : processPL tail

process ACTs, SCENEs and SPEECHs

> processRealContent :: [SimpleXML] -> Int -> [SimpleXML]
> processRealContent [] layer = []
> processRealContent (s : tail) layer = processLayer s (layer + 1) ++ processRealContent tail layer

> processContent :: [SimpleXML] -> Int -> [SimpleXML]
> processContent [] layer = []
> processContent (s : tail) layer = 
>	 if layer == 1 then processPAE s ++ processRealContent tail layer
>	 else if layer == 4 then processPL (s : tail)
>	 else processRealContent (s : tail) layer

Layer 1 PLAY   = TITLE : PERSONAE : ACTs
Layer 2 ACT    = TITLE : SCENEs
Layer 3 SCENE  = TITLE : SPEECHs
Layer 4 SPEECH = SPEAKER : LINEs

> processLayer :: SimpleXML -> Int -> [SimpleXML]
> processLayer (PCDATA a) layer = [PCDATA a]
> processLayer (Element _title (title : tail)) layer =
>	 if layer < 4 then processTitle title layer : processContent tail layer
>	 else processSpeaker title ++ processContent tail layer

> formatPlay :: SimpleXML -> SimpleXML
> formatPlay xml = Element "html" [(Element "body" (processLayer xml 1))]  

The main action that we've provided below will use your function to
generate a ﬁle `dream.html` from the sample play. The contents of this
ﬁle after your program runs must be character-for-character identical
to `sample.html`.

> mainXML = do writeFile "dream.html" $ xml2string $ formatPlay play
>              testResults "dream.html" "sample.html"
>
> firstDiff :: Eq a => [a] -> [a] -> Maybe ([a],[a])
> firstDiff [] [] = Nothing
> firstDiff (c:cs) (d:ds) 
>      | c==d = firstDiff cs ds 
>      | otherwise = Just (c:cs, d:ds)
> firstDiff cs ds = Just (cs,ds)
> 
> testResults :: String -> String -> IO ()
> testResults file1 file2 = do 
>   f1 <- readFile file1
>   f2 <- readFile file2
>   case firstDiff f1 f2 of
>     Nothing -> do
>       putStr "Success!\n"
>     Just (cs,ds) -> do
>       putStr "Results differ: '"
>       putStr (take 20 cs)
>       putStr "' vs '"
>       putStr (take 20 ds)
>       putStr "'\n"

Important: The purpose of this assignment is not just to "get the job
done" --- i.e., to produce the right HTML. A more important goal is to
think about what is a good way to do this job, and jobs like it. To
this end, your solution should be organized into two parts:

1. a collection of generic functions for transforming XML structures
   that have nothing to do with plays, plus

2. a short piece of code (a single deﬁnition or a collection of short
   deﬁnitions) that uses the generic functions to do the particular
   job of transforming a play into HTML.

Obviously, there are many ways to do the ﬁrst part. The main challenge
of the assignment is to ﬁnd a clean design that matches the needs of
the second part.

You will be graded not only on correctness (producing the required
output), but also on the elegance of your solution and the clarity and
readability of your code and documentation.  Style counts.  It is
strongly recommended that you rewrite this part of the assignment a
couple of times: get something working, then step back and see if
there is anything you can abstract out or generalize, rewrite it, then
leave it alone for a few hours or overnight and rewrite it again. Try
to use some of the higher-order programming techniques we've been
discussing in class.

Submission Instructions
-----------------------

* If working with a partner, you should both submit your assignments
  individually.
* Make sure your `hw1.lhs` is accepted by GHC without errors or warnings.
* Attach your `hw1.hs` file in an email to `cse230@goto.ucsd.edu` with the
  subject "HW1" (minus the quotes).
  *This address is unmonitored!*

Credits
-------

This homework is essentially Homeworks 1 & 2 from
<a href="http://www.cis.upenn.edu/~bcpierce/courses/552-2008/index.html">UPenn's CIS 552</a>.
