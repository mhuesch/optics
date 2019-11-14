{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -fplugin=Test.Inspection.Plugin -dsuppress-all #-}
module Optics.Tests.Misc (miscTests) where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Inspection
import qualified Data.Map as M
import qualified Data.Sequence as S

import Optics
import Optics.Tests.Utils

miscTests :: TestTree
miscTests = testGroup "Miscellaneous"
  [ testCase "optimized sipleMapIx" $
    assertSuccess $(inspectTest $ 'simpleMapIx `hasNoTypeClassesExcept` [''Ord])
  , testCase "optimized mapIx" $
    assertSuccess $(inspectTest $ hasNoProfunctors 'mapIx)
  , testCase "optimized seqIx" $
    assertSuccess $(inspectTest $ hasNoProfunctors 'seqIx)
  , testCase "optimized itoList" $
    assertSuccess $(inspectTest $ hasNoProfunctors 'checkitoListOf)
  , testCase "optimized partsOf" $
    ghc80failure $(inspectTest $ hasNoProfunctors 'checkPartsOf)
  , testCase "optimized singular" $
    ghc80failure $(inspectTest $ hasNoProfunctors 'checkSingular)
  ]

simpleMapIx
  :: Ord k => k -> Either a (M.Map k (b, v)) -> Maybe v
simpleMapIx k = preview (_Right % ix k % _2)

mapIx
  :: (Foldable f, Foldable g, Ord k)
  => (f (Either a (g (M.Map k v))), b) -> k -> [v]
mapIx m k = toListOf (_1 % folded % _Right % folded % ix k) m

seqIx :: Int -> [S.Seq a] -> [a]
seqIx i = toListOf (folded % ix i)

checkitoListOf :: Int -> [S.Seq a] -> [(Int, a)]
checkitoListOf i = itoListOf (ifolded % ix i)

checkPartsOf
  :: Traversable f
  => (f (Either a b), c)
  -> (f (Either a b), c)
checkPartsOf = partsOf (_1 % traversed % _Right) %~ reverse

checkSingular
  :: Traversable f
  => Either (f (a, Char)) b
  -> Either (f (a, Char)) b
checkSingular = singular (_Left % traversed % _2) .~ 'x'
