{-*********************************************************}
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| XXTEA.hs                                                 |
|                                                          |
| Release 3.0                                              |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Chen fei <cf850118@163.com>                    |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
{*********************************************************-}

{- XXTEA encryption arithmetic library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 17, 2009
* This library is free.  You can redistribute it and/or modify it.
-}

module PHPRPC.Util.XXTEA(encrypt, decrypt) where

import Char
import Bits
import Word

delta :: Word32
delta = 0x9e3779b9

intToWord32 :: Int -> Word32
intToWord32 w = fromIntegral w

word32ToInt :: Word32 -> Int
word32ToInt w = fromIntegral w

charToWord32 :: Char -> Word32
charToWord32 c = fromIntegral (ord c)

word32ToChar :: Word32 -> Char
word32ToChar w = chr ((fromIntegral w) .&. 0xff)

mx :: Word32 -> Word32 -> [Word32] -> Word32 -> Word32 -> Word32 -> Word32
mx y z key p e sum =
    ((((z `shiftR` 5) .&. 0x07ffffff) `xor` (y `shiftL` 2)) + (((y `shiftR` 3) .&. 0x1fffffff) `xor` (z `shiftL` 4))) `xor`
	((sum `xor` y) + (key !! (word32ToInt (p .&. 3 `xor` e))) `xor` z)

encrypt :: String -> String -> String
encrypt value key = toCharList (encryptList (toWord32List value True) (toWord32List key False)) False
	where
		encryptList :: [Word32] -> [Word32] -> [Word32]
		encryptList value key | length value < 2 = value
		encryptList value key | length key < 4 = encryptList value newKey
			where
				newKey = key ++ (replicate (4 - (length key)) 0)
		encryptList value key = encryptLoop1 value key (last value) 0 q
			where 
				n = (length value) - 1
				q = 6 + 52 `div` (n + 1)
				encryptLoop1 :: [Word32] -> [Word32] -> Word32 -> Word32 -> Int -> [Word32]
				encryptLoop1 value _key _z _sum 0 = value
				encryptLoop1 value key z sum q = encryptLoop2 value key [] z sum2 e 0 (q - 1)
					where
						sum2 = sum + delta
						e = (sum2 `shiftR` 2) .&. 3
						encryptLoop2 :: [Word32] -> [Word32] -> [Word32] -> Word32 -> Word32 -> Word32 -> Word32 -> Int -> [Word32]
						encryptLoop2 [x] key list z sum e p q = encryptLoop1 (reverse (z2 : list)) key z2 sum q
							where
								z2 = x + (mx (last list) z key p e sum)
						encryptLoop2 (x : y : t) key list z sum e p q = encryptLoop2 (y : t) key (z2 : list) z2 sum e (p + 1) q
							where
								z2 = x + (mx y z key p e sum)
								

decrypt :: String -> String -> String	
decrypt value key = toCharList (decryptList (toWord32List value False) (toWord32List key False)) True
	where
		decryptList :: [Word32] -> [Word32] -> [Word32]
		decryptList value key | length key < 4 = decryptList value newKey
			where
				newKey = key ++ (replicate (4 - (length key)) 0)
		decryptList value key = decryptLoop1 value key ((intToWord32 q) * delta) (head value) n
			where
				n = (length value) - 1
				q = 6 + 52 `div` (n + 1)
				decryptLoop1 :: [Word32] -> [Word32] -> Word32 -> Word32 -> Int -> [Word32]
				decryptLoop1 value _key 0 _y _n = value
				decryptLoop1 value _key sum y n = decryptLoop2 (reverse value) key [] y sum ((sum `shiftR` 2) .&. 3) n n
					where
						decryptLoop2 :: [Word32] -> [Word32] -> [Word32] -> Word32 -> Word32 -> Word32 -> Int -> Int -> [Word32]
						decryptLoop2 [x] key list y sum e p n = decryptLoop1 (y2 : list) key (sum - delta) y2 n
							where
								y2 = x - (mx y (last list) key (intToWord32 p) e sum)
						decryptLoop2 (x : z : t) key list y sum e p n =	decryptLoop2 (z : t) key (y2 : list) y2 sum e (p - 1) n
							where
								y2 = x - (mx y z key (intToWord32 p) e sum)
				
-- Convert String to Word32 list.	
toWord32List :: String -> Bool -> [Word32]
toWord32List value incLen = if incLen then l ++ [intToWord32 (length value)] else l
	where
		l = toWord32List value 0 0
		toWord32List :: String -> Word32 -> Int -> [Word32]
		toWord32List (h:t) acc i = case j `rem` 4 of
			0 -> v : toWord32List t 0 j
			_ -> toWord32List t v j
			where
				j = i + 1
				v = acc .|. ((charToWord32 h) `shiftL`  ((i .&. 3) `shiftL`  3))
		toWord32List [] 0 _I = []
		toWord32List [] acc _I = [acc]

-- Convert Word32 list to String.		
toCharList :: [Word32] -> Bool -> String		
toCharList value incLen = if incLen then
		if m < n then toCharList value 0 m else []
	else
		toCharList value 0 n
	where
		m = word32ToInt (last value)
		n = length(value) `shiftL` 2
		toCharList :: [Word32] -> Int -> Int -> String
		toCharList _ i max | i == max = []
		toCharList (h:t) i max = case j `rem` 4 of
			0 -> v : toCharList t j max
			_ -> v : toCharList (h:t) j max
			where
				j = i + 1
				v = word32ToChar (h `shiftR` ((i .&. 3) `shiftL` 3))
