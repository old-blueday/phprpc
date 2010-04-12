/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| BigInteger.cs                                            |
|                                                          |
| Release 3.0.2                                            |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Ma Bingyao <andot@ujn.edu.cn>                  |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* Big Integer implementation
 *
 * Authors:
 *	Ben Maurer
 *	Chew Keong TAN
 *	Sebastien Pouliot <sebastien@ximian.com>
 *	Pieter Philippaerts <Pieter@mentalis.org>
 *  Ma Bingyao <andot@ujn.edu.cn>
 *
 * Copyright (c) 2003 Ben Maurer
 * All rights reserved
 *
 * Copyright (c) 2002 Chew Keong TAN
 * All rights reserved.
 *
 * Copyright (C) 2004, 2007 Novell, Inc (http://www.novell.com)
 
 * Copyright (C) 2008 Ma Bingyao <andot@ujn.edu.cn>
 * 
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    using System;
#if !(PocketPC || Smartphone)
    using System.Security.Cryptography;
#endif

    public class BigInteger {

        #region Data Storage

        UInt32 length = 1;
        UInt32[] data;

        #endregion

        #region Constants

        const UInt32 DEFAULT_LEN = 20;

        public enum Sign : int {
            Negative = -1,
            Zero = 0,
            Positive = 1
        };

        #region Exception Messages
        const String WouldReturnNegVal = "Operation would return a negative value";
        #endregion

        #endregion

        #region Constructors

        public BigInteger() {
            data = new UInt32[DEFAULT_LEN];
            this.length = DEFAULT_LEN;
        }

        public BigInteger(Sign sign, UInt32 len) {
            this.data = new UInt32[len];
            this.length = len;
        }

        public BigInteger(BigInteger bi) {
            this.data = (UInt32[])bi.data.Clone();
            this.length = bi.length;
        }

        public BigInteger(BigInteger bi, UInt32 len) {

            this.data = new UInt32[len];

            for (UInt32 i = 0; i < bi.length; i++) {
                this.data[i] = bi.data[i];
            }

            this.length = bi.length;
        }

        #endregion

        #region Conversions

        public BigInteger(byte[] inData) {
            length = (UInt32)inData.Length >> 2;
            Int32 leftOver = inData.Length & 0x3;

            // length not multiples of 4
            if (leftOver != 0) {
                length++;
            }

            data = new UInt32[length];

            for (Int32 i = inData.Length - 1, j = 0; i >= 3; i -= 4, j++) {
                data[j] = (UInt32)(((UInt32)inData[i - 3] << 24) | ((UInt32)inData[i - 2] << 16) | ((UInt32)inData[i - 1] << 8) | (UInt32)inData[i]);
            }

            switch (leftOver) {
            case 1:
                data[length - 1] = (UInt32)inData[0];
                break;
            case 2:
                data[length - 1] = (((UInt32)inData[0] << 8) | (UInt32)inData[1]);
                break;
            case 3:
                data[length - 1] = (((UInt32)inData[0] << 16) | ((UInt32)inData[1] << 8) | (UInt32)inData[2]);
                break;
            }

            this.Normalize();
        }

        public BigInteger(UInt32[] inData) {
            length = (UInt32)inData.Length;

            data = new UInt32[length];

            for (Int32 i = (Int32)length - 1, j = 0; i >= 0; i--, j++) {
                data[j] = inData[i];
            }

            this.Normalize();
        }

        public BigInteger(UInt32 ui) {
            data = new UInt32[] { ui };
        }

        public BigInteger(UInt64 ul) {
            data = new UInt32[2] { (UInt32)ul, (UInt32)(ul >> 32) };
            length = 2;

            this.Normalize();
        }

        public static implicit operator BigInteger(UInt32 value) {
            return (new BigInteger(value));
        }

        public static implicit operator BigInteger(Int32 value) {
            if (value < 0) {
                throw new ArgumentOutOfRangeException("value");
            }
            return (new BigInteger((UInt32)value));
        }

        public static implicit operator BigInteger(UInt64 value) {
            return (new BigInteger(value));
        }

        /* This is the BigInteger.Parse method I use. This method works
        because BigInteger.ToString returns the input I gave to Parse. */
        public static BigInteger Parse(String number) {
            if (number == null) {
                throw new ArgumentNullException("number");
            }

            Int32 i = 0, len = number.Length;
            Char c;
            Boolean digits_seen = false;
            BigInteger val = new BigInteger(0);
            if (number[i] == '+') {
                i++;
            }
            else if (number[i] == '-') {
                throw new FormatException(WouldReturnNegVal);
            }

            for (; i < len; i++) {
                c = number[i];
                if (c == '\0') {
                    i = len;
                    continue;
                }
                if (c >= '0' && c <= '9') {
                    val = val * 10 + (c - '0');
                    digits_seen = true;
                }
                else {
                    if (Char.IsWhiteSpace(c)) {
                        for (i++; i < len; i++) {
                            if (!Char.IsWhiteSpace(number[i])) {
                                throw new FormatException();
                            }
                        }
                        break;
                    }
                    else {
                        throw new FormatException();
                    }
                }
            }
            if (!digits_seen) {
                throw new FormatException();
            }
            return val;
        }

        #endregion

        #region Operators

        public static BigInteger operator +(BigInteger bi1, BigInteger bi2) {
            if (bi1 == 0) {
                return new BigInteger(bi2);
            }
            else if (bi2 == 0) {
                return new BigInteger(bi1);
            }
            else {
                return Kernel.AddSameSign(bi1, bi2);
            }
        }

        public static BigInteger operator -(BigInteger bi1, BigInteger bi2) {
            if (bi2 == 0) {
                return new BigInteger(bi1);
            }

            if (bi1 == 0) {
                throw new ArithmeticException(WouldReturnNegVal);
            }

            switch (Kernel.Compare(bi1, bi2)) {

            case Sign.Zero:
                return 0;

            case Sign.Positive:
                return Kernel.Subtract(bi1, bi2);

            case Sign.Negative:
                throw new ArithmeticException(WouldReturnNegVal);
            default:
                throw new Exception();
            }
        }

        public static Int32 operator %(BigInteger bi, Int32 i) {
            if (i > 0) {
                return (Int32)Kernel.DwordMod(bi, (UInt32)i);
            }
            else {
                return -(Int32)Kernel.DwordMod(bi, (UInt32)(-i));
            }
        }

        public static UInt32 operator %(BigInteger bi, UInt32 ui) {
            return Kernel.DwordMod(bi, (UInt32)ui);
        }

        public static BigInteger operator %(BigInteger bi1, BigInteger bi2) {
            return Kernel.multiByteDivide(bi1, bi2)[1];
        }

        public static BigInteger operator /(BigInteger bi, Int32 i) {
            if (i > 0) {
                return Kernel.DwordDiv(bi, (UInt32)i);
            }

            throw new ArithmeticException(WouldReturnNegVal);
        }

        public static BigInteger operator /(BigInteger bi1, BigInteger bi2) {
            return Kernel.multiByteDivide(bi1, bi2)[0];
        }

        public static BigInteger operator *(BigInteger bi1, BigInteger bi2) {
            if (bi1 == 0 || bi2 == 0) {
                return 0;
            }

            //
            // Validate pointers
            //
            if (bi1.data.Length < bi1.length) {
                throw new IndexOutOfRangeException("bi1 out of range");
            }
            if (bi2.data.Length < bi2.length) {
                throw new IndexOutOfRangeException("bi2 out of range");
            }

            BigInteger ret = new BigInteger(Sign.Positive, bi1.length + bi2.length);

            Kernel.Multiply(bi1.data, 0, bi1.length, bi2.data, 0, bi2.length, ret.data, 0);

            ret.Normalize();
            return ret;
        }

        public static BigInteger operator *(BigInteger bi, Int32 i) {
            if (i < 0) {
                throw new ArithmeticException(WouldReturnNegVal);
            }
            if (i == 0) {
                return 0;
            }
            if (i == 1) {
                return new BigInteger(bi);
            }

            return Kernel.MultiplyByDword(bi, (UInt32)i);
        }

        public static BigInteger operator <<(BigInteger bi1, Int32 shiftVal) {
            return Kernel.LeftShift(bi1, shiftVal);
        }

        public static BigInteger operator >>(BigInteger bi1, Int32 shiftVal) {
            return Kernel.RightShift(bi1, shiftVal);
        }

        #endregion

        #region Friendly names for operators

        // with names suggested by FxCop 1.30

        public static BigInteger Add(BigInteger bi1, BigInteger bi2) {
            return (bi1 + bi2);
        }

        public static BigInteger Subtract(BigInteger bi1, BigInteger bi2) {
            return (bi1 - bi2);
        }

        public static Int32 Modulus(BigInteger bi, Int32 i) {
            return (bi % i);
        }

        public static UInt32 Modulus(BigInteger bi, UInt32 ui) {
            return (bi % ui);
        }

        public static BigInteger Modulus(BigInteger bi1, BigInteger bi2) {
            return (bi1 % bi2);
        }

        public static BigInteger Divid(BigInteger bi, Int32 i) {
            return (bi / i);
        }

        public static BigInteger Divid(BigInteger bi1, BigInteger bi2) {
            return (bi1 / bi2);
        }

        public static BigInteger Multiply(BigInteger bi1, BigInteger bi2) {
            return (bi1 * bi2);
        }

        public static BigInteger Multiply(BigInteger bi, Int32 i) {
            return (bi * i);
        }

        #endregion

        #region Random
#if PocketPC || Smartphone || SILVERLIGHT
        private static Random rng;
        private static Random Rng {
            get {
                if (rng == null) {
                    rng = new Random((int)DateTime.Now.Ticks);
                }
                return rng;
            }
        }
#else
        private static RandomNumberGenerator rng;
        private static RandomNumberGenerator Rng {
            get {
                if (rng == null) {
                    rng = RandomNumberGenerator.Create();
                }
                return rng;
            }
        }
#endif

#if PocketPC || Smartphone || SILVERLIGHT
        public static BigInteger GenerateRandom(Int32 bits, Random rng) {
#else
        public static BigInteger GenerateRandom(Int32 bits, RandomNumberGenerator rng) {
#endif
            Int32 dwords = bits >> 5;
            Int32 remBits = bits & 0x1F;

            if (remBits != 0) {
                dwords++;
            }

            BigInteger ret = new BigInteger(Sign.Positive, (UInt32)dwords + 1);
            byte[] random = new byte[dwords << 2];

#if PocketPC || Smartphone || SILVERLIGHT
            rng.NextBytes(random);
#else
            rng.GetBytes(random);
#endif
            Buffer.BlockCopy(random, 0, ret.data, 0, (Int32)dwords << 2);

            if (remBits != 0) {
                UInt32 mask = (UInt32)(0x01 << (remBits - 1));
                ret.data[dwords - 1] |= mask;

                mask = (UInt32)(0xFFFFFFFF >> (32 - remBits));
                ret.data[dwords - 1] &= mask;
            }
            else {
                ret.data[dwords - 1] |= 0x80000000;
            }

            ret.Normalize();
            return ret;
        }

        public static BigInteger GenerateRandom(Int32 bits) {
            return GenerateRandom(bits, Rng);
        }

#if PocketPC || Smartphone || SILVERLIGHT
        public void Randomize(Random rng) {
#else
        public void Randomize(RandomNumberGenerator rng) {
#endif
            if (this == 0) {
                return;
            }

            Int32 bits = this.BitCount();
            Int32 dwords = bits >> 5;
            Int32 remBits = bits & 0x1F;

            if (remBits != 0) {
                dwords++;
            }

            byte[] random = new byte[dwords << 2];

#if PocketPC || Smartphone || SILVERLIGHT
            rng.NextBytes(random);
#else
            rng.GetBytes(random);
#endif
            Buffer.BlockCopy(random, 0, data, 0, (Int32)dwords << 2);

            if (remBits != 0) {
                UInt32 mask = (UInt32)(0x01 << (remBits - 1));
                data[dwords - 1] |= mask;

                mask = (UInt32)(0xFFFFFFFF >> (32 - remBits));
                data[dwords - 1] &= mask;
            }
            else {
                data[dwords - 1] |= 0x80000000;
            }

            Normalize();
        }

        public void Randomize() {
            Randomize(Rng);
        }

        #endregion

        #region Bitwise

        public Int32 BitCount() {
            this.Normalize();

            UInt32 value = data[length - 1];
            UInt32 mask = 0x80000000;
            UInt32 bits = 32;

            while (bits > 0 && (value & mask) == 0) {
                bits--;
                mask >>= 1;
            }
            bits += ((length - 1) << 5);

            return (Int32)bits;
        }

        public Boolean TestBit(UInt32 bitNum) {
            UInt32 bytePos = bitNum >> 5;             // divide by 32
            byte bitPos = (byte)(bitNum & 0x1F);    // get the lowest 5 bits

            UInt32 mask = (UInt32)1 << bitPos;
            return ((this.data[bytePos] & mask) != 0);
        }

        public Boolean TestBit(Int32 bitNum) {
            if (bitNum < 0) {
                throw new IndexOutOfRangeException("bitNum out of range");
            }

            UInt32 bytePos = (UInt32)bitNum >> 5;             // divide by 32
            byte bitPos = (byte)(bitNum & 0x1F);    // get the lowest 5 bits

            UInt32 mask = (UInt32)1 << bitPos;
            return ((this.data[bytePos] | mask) == this.data[bytePos]);
        }

        public void SetBit(UInt32 bitNum) {
            SetBit(bitNum, true);
        }

        public void ClearBit(UInt32 bitNum) {
            SetBit(bitNum, false);
        }

        public void SetBit(UInt32 bitNum, Boolean value) {
            UInt32 bytePos = bitNum >> 5;             // divide by 32

            if (bytePos < this.length) {
                UInt32 mask = (UInt32)1 << (Int32)(bitNum & 0x1F);
                if (value) {
                    this.data[bytePos] |= mask;
                }
                else {
                    this.data[bytePos] &= ~mask;
                }
            }
        }

        public Int32 LowestSetBit() {
            if (this == 0) {
                return -1;
            }
            Int32 i = 0;
            while (!TestBit(i)) {
                i++;
            }
            return i;
        }

        public byte[] GetBytes() {
            if (this == 0) {
                return new byte[1];
            }

            Int32 numBits = BitCount();
            Int32 numBytes = numBits >> 3;
            if ((numBits & 0x7) != 0) {
                numBytes++;
            }

            byte[] result = new byte[numBytes];

            Int32 numBytesInWord = numBytes & 0x3;
            if (numBytesInWord == 0) {
                numBytesInWord = 4;
            }

            Int32 pos = 0;
            for (Int32 i = (Int32)length - 1; i >= 0; i--) {
                UInt32 val = data[i];
                for (Int32 j = numBytesInWord - 1; j >= 0; j--) {
                    result[pos + j] = (byte)(val & 0xFF);
                    val >>= 8;
                }
                pos += numBytesInWord;
                numBytesInWord = 4;
            }
            return result;
        }

        #endregion

        #region Compare

        public static Boolean operator ==(BigInteger bi1, UInt32 ui) {
            if (bi1.length != 1) {
                bi1.Normalize();
            }
            return bi1.length == 1 && bi1.data[0] == ui;
        }

        public static Boolean operator !=(BigInteger bi1, UInt32 ui) {
            if (bi1.length != 1) {
                bi1.Normalize();
            }
            return !(bi1.length == 1 && bi1.data[0] == ui);
        }

        public static Boolean operator ==(BigInteger bi1, BigInteger bi2) {
            // we need to compare with null
            if ((bi1 as Object) == (bi2 as Object)) {
                return true;
            }
            if (null == bi1 || null == bi2) {
                return false;
            }
            return Kernel.Compare(bi1, bi2) == 0;
        }

        public static Boolean operator !=(BigInteger bi1, BigInteger bi2) {
            // we need to compare with null
            if ((bi1 as Object) == (bi2 as Object)) {
                return false;
            }
            if (null == bi1 || null == bi2) {
                return true;
            }
            return Kernel.Compare(bi1, bi2) != 0;
        }

        public static Boolean operator >(BigInteger bi1, BigInteger bi2) {
            return Kernel.Compare(bi1, bi2) > 0;
        }

        public static Boolean operator <(BigInteger bi1, BigInteger bi2) {
            return Kernel.Compare(bi1, bi2) < 0;
        }

        public static Boolean operator >=(BigInteger bi1, BigInteger bi2) {
            return Kernel.Compare(bi1, bi2) >= 0;
        }

        public static Boolean operator <=(BigInteger bi1, BigInteger bi2) {
            return Kernel.Compare(bi1, bi2) <= 0;
        }

        public Sign Compare(BigInteger bi) {
            return Kernel.Compare(this, bi);
        }

        #endregion

        #region Formatting

        public String ToString(UInt32 radix) {
            return ToString(radix, "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ");
        }

        public String ToString(UInt32 radix, String characterSet) {
            if (characterSet.Length < radix)
                throw new ArgumentException("charSet length less than radix", "characterSet");
            if (radix == 1)
                throw new ArgumentException("There is no such thing as radix one notation", "radix");

            if (this == 0)
                return "0";
            if (this == 1)
                return "1";

            String result = "";

            BigInteger a = new BigInteger(this);

            while (a != 0) {
                UInt32 rem = Kernel.SingleByteDivideInPlace(a, radix);
                result = characterSet[(Int32)rem] + result;
            }

            return result;
        }

        #endregion

        #region Misc

        private void Normalize() {
            // Normalize length
            while (length > 0 && data[length - 1] == 0) {
                length--;
            }
            // Check for zero
            if (length == 0) {
                length++;
            }
        }

        public void Clear() {
            for (Int32 i = 0; i < length; i++) {
                data[i] = 0x00;
            }
        }

        #endregion

        #region Object Impl

        public override Int32 GetHashCode() {
            UInt32 val = 0;

            for (UInt32 i = 0; i < this.length; i++)
                val ^= this.data[i];

            return (Int32)val;
        }

        public override String ToString() {
            return ToString(10);
        }

        public override Boolean Equals(Object o) {
            if (o == null)
                return false;
            if (o is Int32)
                return (Int32)o >= 0 && this == (UInt32)o;

            BigInteger bi = o as BigInteger;
            if (bi == null)
                return false;

            return Kernel.Compare(this, bi) == 0;
        }

        #endregion

        #region Number Theory

        public BigInteger ModPow(BigInteger exp, BigInteger n) {
            ModulusRing mr = new ModulusRing(n);
            return mr.Pow(this, exp);
        }

        #endregion

        public sealed class ModulusRing {

            BigInteger mod, constant;

            public ModulusRing(BigInteger modulus) {
                this.mod = modulus;

                // calculate constant = b^ (2k) / m
                UInt32 i = mod.length << 1;

                constant = new BigInteger(Sign.Positive, i + 1);
                constant.data[i] = 0x00000001;

                constant = constant / mod;
            }

            public void BarrettReduction(BigInteger x) {
                BigInteger n = mod;
                UInt32 k = n.length,
                    kPlusOne = k + 1,
                    kMinusOne = k - 1;

                // x < mod, so nothing to do.
                if (x.length < k) {
                    return;
                }

                BigInteger q3;

                //
                // Validate pointers
                //
                if (x.data.Length < x.length) {
                    throw new IndexOutOfRangeException("x out of range");
                }

                // q1 = x / b^ (k-1)
                // q2 = q1 * constant
                // q3 = q2 / b^ (k+1), Needs to be accessed with an offset of kPlusOne

                // TODO: We should the method in HAC p 604 to do this (14.45)
                q3 = new BigInteger(Sign.Positive, x.length - kMinusOne + constant.length);
                Kernel.Multiply(x.data, kMinusOne, x.length - kMinusOne, constant.data, 0, constant.length, q3.data, 0);

                // r1 = x mod b^ (k+1)
                // i.e. keep the lowest (k+1) words

                UInt32 lengthToCopy = (x.length > kPlusOne) ? kPlusOne : x.length;

                x.length = lengthToCopy;
                x.Normalize();

                // r2 = (q3 * n) mod b^ (k+1)
                // partial multiplication of q3 and n

                BigInteger r2 = new BigInteger(Sign.Positive, kPlusOne);
                Kernel.MultiplyMod2p32pmod(q3.data, (Int32)kPlusOne, (Int32)q3.length - (Int32)kPlusOne, n.data, 0, (Int32)n.length, r2.data, 0, (Int32)kPlusOne);

                r2.Normalize();

                if (r2 <= x) {
                    Kernel.MinusEq(x, r2);
                }
                else {
                    BigInteger val = new BigInteger(Sign.Positive, kPlusOne + 1);
                    val.data[kPlusOne] = 0x00000001;

                    Kernel.MinusEq(val, r2);
                    Kernel.PlusEq(x, val);
                }

                while (x >= n) {
                    Kernel.MinusEq(x, n);
                }
            }

            public BigInteger Multiply(BigInteger a, BigInteger b) {
                if (a == 0 || b == 0) {
                    return 0;
                }

                if (a > mod) {
                    a %= mod;
                }

                if (b > mod) {
                    b %= mod;
                }

                BigInteger ret = new BigInteger(a * b);
                BarrettReduction(ret);

                return ret;
            }

            public BigInteger Difference(BigInteger a, BigInteger b) {
                Sign cmp = Kernel.Compare(a, b);
                BigInteger diff;

                switch (cmp) {
                case Sign.Zero:
                    return 0;
                case Sign.Positive:
                    diff = a - b;
                    break;
                case Sign.Negative:
                    diff = b - a;
                    break;
                default:
                    throw new Exception();
                }

                if (diff >= mod) {
                    if (diff.length >= mod.length << 1) {
                        diff %= mod;
                    }
                    else {
                        BarrettReduction(diff);
                    }
                }
                if (cmp == Sign.Negative) {
                    diff = mod - diff;
                }
                return diff;
            }

            public BigInteger Pow(BigInteger a, BigInteger k) {
                BigInteger b = new BigInteger(1);
                if (k == 0) {
                    return b;
                }

                BigInteger A = a;
                if (k.TestBit(0)) {
                    b = a;
                }

                for (Int32 i = 1; i < k.BitCount(); i++) {
                    A = Multiply(A, A);
                    if (k.TestBit(i)) {
                        b = Multiply(A, b);
                    }
                }
                return b;
            }

            #region Pow Small Base

            // TODO: Make tests for this, not really needed b/c prime stuff
            // checks it, but still would be nice
            public BigInteger Pow(UInt32 b, BigInteger exp) {
                return Pow(new BigInteger(b), exp);
            }
            #endregion
        }

        private sealed class Kernel {

            #region Addition/Subtraction

            public static BigInteger AddSameSign(BigInteger bi1, BigInteger bi2) {
                UInt32[] x, y;
                UInt32 yMax, xMax, i = 0;

                // x should be bigger
                if (bi1.length < bi2.length) {
                    x = bi2.data;
                    xMax = bi2.length;
                    y = bi1.data;
                    yMax = bi1.length;
                }
                else {
                    x = bi1.data;
                    xMax = bi1.length;
                    y = bi2.data;
                    yMax = bi2.length;
                }

                BigInteger result = new BigInteger(Sign.Positive, xMax + 1);

                UInt32[] r = result.data;

                UInt64 sum = 0;

                // Add common parts of both numbers
                do {
                    sum = ((UInt64)x[i]) + ((UInt64)y[i]) + sum;
                    r[i] = (UInt32)sum;
                    sum >>= 32;
                } while (++i < yMax);

                // Copy remainder of longer number while carry propagation is required
                Boolean carry = (sum != 0);

                if (carry) {
                    if (i < xMax) {
                        do {
                            carry = ((r[i] = x[i] + 1) == 0);
                        } while (++i < xMax && carry);
                    }
                    if (carry) {
                        r[i] = 1;
                        result.length = ++i;
                        return result;
                    }
                }

                // Copy the rest
                if (i < xMax) {
                    do {
                        r[i] = x[i];
                    } while (++i < xMax);
                }

                result.Normalize();
                return result;
            }

            public static BigInteger Subtract(BigInteger big, BigInteger small) {
                BigInteger result = new BigInteger(Sign.Positive, big.length);

                UInt32[] r = result.data, b = big.data, s = small.data;
                UInt32 i = 0, c = 0;

                do {
                    UInt32 x = s[i];
                    if (((x += c) < c) | ((r[i] = b[i] - x) > ~x)) {
                        c = 1;
                    }
                    else {
                        c = 0;
                    }
                } while (++i < small.length);

                if (i == big.length) {
                    result.Normalize();
                    return result;
                }

                if (c == 1) {
                    do {
                        r[i] = b[i] - 1;
                    } while (b[i++] == 0 && i < big.length);

                    if (i == big.length) {
                        result.Normalize();
                        return result;
                    }
                }

                do {
                    r[i] = b[i];
                } while (++i < big.length);

                result.Normalize();
                return result;
            }

            public static void MinusEq(BigInteger big, BigInteger small) {
                UInt32[] b = big.data, s = small.data;
                UInt32 i = 0, c = 0;

                do {
                    UInt32 x = s[i];
                    if (((x += c) < c) | ((b[i] -= x) > ~x)) {
                        c = 1;
                    }
                    else {
                        c = 0;
                    }
                } while (++i < small.length);

                if (i != big.length && c == 1) {
                    do {
                        b[i]--;
                    } while (b[i++] == 0 && i < big.length);
                }

                // Normalize length
                while (big.length > 0 && big.data[big.length - 1] == 0) {
                    big.length--;
                }

                // Check for zero
                if (big.length == 0) {
                    big.length++;
                }
            }

            public static void PlusEq(BigInteger bi1, BigInteger bi2) {
                UInt32[] x, y;
                UInt32 yMax, xMax, i = 0;
                Boolean flag = false;

                // x should be bigger
                if (bi1.length < bi2.length) {
                    flag = true;
                    x = bi2.data;
                    xMax = bi2.length;
                    y = bi1.data;
                    yMax = bi1.length;
                }
                else {
                    x = bi1.data;
                    xMax = bi1.length;
                    y = bi2.data;
                    yMax = bi2.length;
                }

                UInt32[] r = bi1.data;

                UInt64 sum = 0;

                // Add common parts of both numbers
                do {
                    sum += ((UInt64)x[i]) + ((UInt64)y[i]);
                    r[i] = (UInt32)sum;
                    sum >>= 32;
                } while (++i < yMax);

                // Copy remainder of longer number while carry propagation is required
                Boolean carry = (sum != 0);

                if (carry) {
                    if (i < xMax) {
                        do {
                            carry = ((r[i] = x[i] + 1) == 0);
                        } while (++i < xMax && carry);
                    }
                    if (carry) {
                        r[i] = 1;
                        bi1.length = ++i;
                        return;
                    }
                }

                // Copy the rest
                if (flag && i < xMax - 1) {
                    do {
                        r[i] = x[i];
                    } while (++i < xMax);
                }

                bi1.length = xMax + 1;
                bi1.Normalize();
            }

            #endregion

            #region Compare

            public static Sign Compare(BigInteger bi1, BigInteger bi2) {
                //
                // Step 1. Compare the lengths
                //
                UInt32 l1 = bi1.length, l2 = bi2.length;

                while (l1 > 0 && bi1.data[l1 - 1] == 0) {
                    l1--;
                }
                while (l2 > 0 && bi2.data[l2 - 1] == 0) {
                    l2--;
                }

                if (l1 == 0 && l2 == 0) {
                    return Sign.Zero;
                }

                // bi1 len < bi2 len
                if (l1 < l2) {
                    return Sign.Negative;
                }
                // bi1 len > bi2 len
                else if (l1 > l2) {
                    return Sign.Positive;
                }

                //
                // Step 2. Compare the bits
                //

                UInt32 pos = l1 - 1;

                while (pos != 0 && bi1.data[pos] == bi2.data[pos]) {
                    pos--;
                }

                if (bi1.data[pos] < bi2.data[pos]) {
                    return Sign.Negative;
                }
                else if (bi1.data[pos] > bi2.data[pos]) {
                    return Sign.Positive;
                }
                else {
                    return Sign.Zero;
                }
            }

            #endregion

            #region Division

            #region Dword

            public static UInt32 SingleByteDivideInPlace(BigInteger n, UInt32 d) {
                UInt64 r = 0;
                UInt32 i = n.length;

                while (i-- > 0) {
                    r <<= 32;
                    r |= n.data[i];
                    n.data[i] = (UInt32)(r / d);
                    r %= d;
                }
                n.Normalize();

                return (UInt32)r;
            }

            public static UInt32 DwordMod(BigInteger n, UInt32 d) {
                UInt64 r = 0;
                UInt32 i = n.length;

                while (i-- > 0) {
                    r <<= 32;
                    r |= n.data[i];
                    r %= d;
                }

                return (UInt32)r;
            }

            public static BigInteger DwordDiv(BigInteger n, UInt32 d) {
                BigInteger ret = new BigInteger(Sign.Positive, n.length);

                UInt64 r = 0;
                UInt32 i = n.length;

                while (i-- > 0) {
                    r <<= 32;
                    r |= n.data[i];
                    ret.data[i] = (UInt32)(r / d);
                    r %= d;
                }
                ret.Normalize();

                return ret;
            }

            public static BigInteger[] DwordDivMod(BigInteger n, UInt32 d) {
                BigInteger ret = new BigInteger(Sign.Positive, n.length);

                UInt64 r = 0;
                UInt32 i = n.length;

                while (i-- > 0) {
                    r <<= 32;
                    r |= n.data[i];
                    ret.data[i] = (UInt32)(r / d);
                    r %= d;
                }
                ret.Normalize();

                BigInteger rem = (UInt32)r;

                return new BigInteger[] { ret, rem };
            }

            #endregion

            #region BigNum

            public static BigInteger[] multiByteDivide(BigInteger bi1, BigInteger bi2) {
                if (Kernel.Compare(bi1, bi2) == Sign.Negative) {
                    return new BigInteger[2] { 0, new BigInteger(bi1) };
                }

                bi1.Normalize();
                bi2.Normalize();

                if (bi2.length == 1) {
                    return DwordDivMod(bi1, bi2.data[0]);
                }

                UInt32 remainderLen = bi1.length + 1;
                Int32 divisorLen = (Int32)bi2.length + 1;

                UInt32 mask = 0x80000000;
                UInt32 val = bi2.data[bi2.length - 1];
                Int32 shift = 0;
                Int32 resultPos = (Int32)bi1.length - (Int32)bi2.length;

                while (mask != 0 && (val & mask) == 0) {
                    shift++;
                    mask >>= 1;
                }

                BigInteger quot = new BigInteger(Sign.Positive, bi1.length - bi2.length + 1);
                BigInteger rem = (bi1 << shift);

                UInt32[] remainder = rem.data;

                bi2 = bi2 << shift;

                Int32 j = (Int32)(remainderLen - bi2.length);
                Int32 pos = (Int32)remainderLen - 1;

                UInt32 firstDivisorByte = bi2.data[bi2.length - 1];
                UInt64 secondDivisorByte = bi2.data[bi2.length - 2];

                while (j > 0) {
                    UInt64 dividend = ((UInt64)remainder[pos] << 32) + (UInt64)remainder[pos - 1];

                    UInt64 q_hat = dividend / (UInt64)firstDivisorByte;
                    UInt64 r_hat = dividend % (UInt64)firstDivisorByte;

                    do {
                        if (q_hat == 0x100000000 ||
                            (q_hat * secondDivisorByte) > ((r_hat << 32) + remainder[pos - 2])) {
                            q_hat--;
                            r_hat += (UInt64)firstDivisorByte;

                            if (r_hat < 0x100000000) {
                                continue;
                            }
                        }
                        break;
                    } while (true);

                    //
                    // At this point, q_hat is either exact, or one too large
                    // (more likely to be exact) so, we attempt to multiply the
                    // divisor by q_hat, if we get a borrow, we just subtract
                    // one from q_hat and add the divisor back.
                    //

                    UInt32 t;
                    UInt32 dPos = 0;
                    Int32 nPos = pos - divisorLen + 1;
                    UInt64 mc = 0;
                    UInt32 uint_q_hat = (UInt32)q_hat;
                    do {
                        mc += (UInt64)bi2.data[dPos] * (UInt64)uint_q_hat;
                        t = remainder[nPos];
                        remainder[nPos] -= (UInt32)mc;
                        mc >>= 32;
                        if (remainder[nPos] > t) {
                            mc++;
                        }
                        dPos++;
                        nPos++;
                    } while (dPos < divisorLen);

                    nPos = pos - divisorLen + 1;
                    dPos = 0;

                    // Overestimate
                    if (mc != 0) {
                        uint_q_hat--;
                        UInt64 sum = 0;

                        do {
                            sum = ((UInt64)remainder[nPos]) + ((UInt64)bi2.data[dPos]) + sum;
                            remainder[nPos] = (UInt32)sum;
                            sum >>= 32;
                            dPos++;
                            nPos++;
                        } while (dPos < divisorLen);

                    }

                    quot.data[resultPos--] = (UInt32)uint_q_hat;

                    pos--;
                    j--;
                }

                quot.Normalize();
                rem.Normalize();
                BigInteger[] ret = new BigInteger[2] { quot, rem };

                if (shift != 0) {
                    ret[1] >>= shift;
                }

                return ret;
            }

            #endregion

            #endregion

            #region Shift
            public static BigInteger LeftShift(BigInteger bi, Int32 n) {
                if (n == 0) {
                    return new BigInteger(bi, bi.length + 1);
                }

                Int32 w = n >> 5;
                n &= ((1 << 5) - 1);

                BigInteger ret = new BigInteger(Sign.Positive, bi.length + 1 + (UInt32)w);

                UInt32 i = 0, l = bi.length;
                if (n != 0) {
                    UInt32 x, carry = 0;
                    while (i < l) {
                        x = bi.data[i];
                        ret.data[i + w] = (x << n) | carry;
                        carry = x >> (32 - n);
                        i++;
                    }
                    ret.data[i + w] = carry;
                }
                else {
                    while (i < l) {
                        ret.data[i + w] = bi.data[i];
                        i++;
                    }
                }

                ret.Normalize();
                return ret;
            }

            public static BigInteger RightShift(BigInteger bi, Int32 n) {
                if (n == 0) {
                    return new BigInteger(bi);
                }

                Int32 w = n >> 5;
                n &= ((1 << 5) - 1);

                BigInteger ret = new BigInteger(Sign.Positive, bi.length - (UInt32)w + 1);
                UInt32 l = (UInt32)ret.data.Length - 1;

                if (n != 0) {
                    UInt32 x, carry = 0;
                    while (l-- > 0) {
                        x = bi.data[l + w];
                        ret.data[l] = (x >> n) | carry;
                        carry = x << (32 - n);
                    }
                }
                else {
                    while (l-- > 0) {
                        ret.data[l] = bi.data[l + w];
                    }
                }
                ret.Normalize();
                return ret;
            }

            #endregion

            #region Multiply

            public static BigInteger MultiplyByDword(BigInteger n, UInt32 f) {
                BigInteger ret = new BigInteger(Sign.Positive, n.length + 1);

                UInt32 i = 0;
                UInt64 c = 0;

                do {
                    c += (UInt64)n.data[i] * (UInt64)f;
                    ret.data[i] = (UInt32)c;
                    c >>= 32;
                } while (++i < n.length);
                ret.data[i] = (UInt32)c;
                ret.Normalize();
                return ret;

            }

            /// <summary>
            /// Multiplies the data in x [xOffset:xOffset+xLen] by
            /// y [yOffset:yOffset+yLen] and puts it into
            /// d [dOffset:dOffset+xLen+yLen].
            /// </summary>
            /// <remarks>
            /// This code is unsafe! It is the caller's responsibility to make
            /// sure that it is safe to access x [xOffset:xOffset+xLen],
            /// y [yOffset:yOffset+yLen], and d [dOffset:dOffset+xLen+yLen].
            /// </remarks>
            public static void Multiply(UInt32[] x, UInt32 xOffset, UInt32 xLen, UInt32[] y, UInt32 yOffset, UInt32 yLen, UInt32[] d, UInt32 dOffset) {
                UInt32 yE = yOffset + yLen;
                for (UInt32 xE = xOffset + xLen; xOffset < xE; xOffset++, dOffset++) {
                    if (x[xOffset] == 0) {
                        continue;
                    }
                    UInt64 mcarry = 0;

                    UInt32 dP = dOffset;
                    for (UInt32 yP = yOffset; yP < yE; yP++, dP++) {
                        mcarry += ((UInt64)x[xOffset] * (UInt64)y[yP]) + (UInt64)d[dP];
                        d[dP] = (UInt32)mcarry;
                        mcarry >>= 32;
                    }

                    if (mcarry != 0) {
                        d[dP] = (UInt32)mcarry;
                    }
                }
            }

            /// <summary>
            /// Multiplies the data in x [xOffset:xOffset+xLen] by
            /// y [yOffset:yOffset+yLen] and puts the low mod words into
            /// d [dOffset:dOffset+mod].
            /// </summary>
            /// <remarks>
            /// This code is unsafe! It is the caller's responsibility to make
            /// sure that it is safe to access x [xOffset:xOffset+xLen],
            /// y [yOffset:yOffset+yLen], and d [dOffset:dOffset+mod].
            /// </remarks>
            public static void MultiplyMod2p32pmod(UInt32[] x, Int32 xOffset, Int32 xLen, UInt32[] y, Int32 yOffest, Int32 yLen, UInt32[] d, Int32 dOffset, Int32 mod) {
                UInt32 xP = (UInt32)xOffset, xE = xP + (UInt32)xLen, yB = (UInt32)yOffest, yE = yB + (UInt32)yLen, dB = (UInt32)dOffset, dE = dB + (UInt32)mod;

                for (; xP < xE; xP++, dB++) {
                    if (x[xP] == 0) {
                        continue;
                    }
                    UInt64 mcarry = 0;
                    UInt32 dP = dB;
                    for (UInt32 yP = yB; yP < yE && dP < dE; yP++, dP++) {
                        mcarry += ((UInt64)x[xP] * (UInt64)y[yP]) + (UInt64)d[dP];
                        d[dP] = (UInt32)mcarry;
                        mcarry >>= 32;
                    }
                    if (mcarry != 0 && dP < dE) {
                        d[dP] = (UInt32)mcarry;
                    }
                }
            }

            public static void SquarePositive(BigInteger bi, ref UInt32[] wkSpace) {
                UInt32[] t = wkSpace;
                wkSpace = bi.data;
                UInt32[] d = bi.data;
                UInt32 dl = bi.length;
                bi.data = t;

                UInt32 ttE = (UInt32)t.Length;
                // Clear the dest
                for (UInt32 ttt = 0; ttt < ttE; ttt++) {
                    t[ttt] = 0;
                }

                UInt32 dP = 0, tP = 0;

                for (UInt32 i = 0; i < dl; i++, dP++) {
                    if (d[dP] == 0) {
                        continue;
                    }
                    UInt64 mcarry = 0;
                    UInt32 bi1val = d[dP];

                    UInt32 dP2 = dP + 1, tP2 = tP + 2 * i + 1;

                    for (UInt32 j = i + 1; j < dl; j++, tP2++, dP2++) {
                        // k = i + j
                        mcarry += ((UInt64)bi1val * (UInt64)d[dP2]) + t[tP2];
                        t[tP2] = (UInt32)mcarry;
                        mcarry >>= 32;
                    }

                    if (mcarry != 0) {
                        t[tP2] = (UInt32)mcarry;
                    }
                }

                // Double t. Inlined for speed.

                tP = 0;

                UInt32 x, carry = 0;
                while (tP < ttE) {
                    x = t[tP];
                    t[tP] = (x << 1) | carry;
                    carry = x >> (32 - 1);
                    tP++;
                }
                if (carry != 0) {
                    t[tP] = carry;
                }

                // Add in the diagnals

                dP = 0;
                tP = 0;
                for (UInt32 dE = dP + dl; (dP < dE); dP++, tP++) {
                    UInt64 val = (UInt64)d[dP] * (UInt64)d[dP] + t[tP];
                    t[tP] = (UInt32)val;
                    val >>= 32;
                    t[(++tP)] += (UInt32)val;
                    if (t[tP] < (UInt32)val) {
                        UInt32 tP3 = tP;
                        // Account for the first carry
                        (t[++tP3])++;

                        // Keep adding until no carry
                        while ((t[tP3++]) == 0) {
                            (t[tP3])++;
                        }
                    }
                }

                bi.length <<= 1;

                // Normalize length
                while (t[bi.length - 1] == 0 && bi.length > 1) {
                    bi.length--;
                }
            }

            #endregion

        }
    }
}
