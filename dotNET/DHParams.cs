/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| DHParams.cs                                              |
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

/* Diffie-Hellman Parameters for PHPRPC.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

#if !(PocketPC || Smartphone || WindowsCE || ClientOnly)
namespace org.phprpc.util {
    using System;
    using System.Collections;
    using System.IO;
    using System.Text;
    using System.Resources;
    using System.Reflection;

    public sealed class DHParams {
        private UInt32 length;
        private Hashtable dhParams;
        private static readonly UInt32[] lengths = { 96, 128, 160, 192, 256, 512, 768, 1024, 1536, 2048, 3072, 4096 };
        private static readonly Hashtable dhParamsGen = new Hashtable(12);
        static DHParams() {
            lock (dhParamsGen.SyncRoot) {
                PHPFormatter formatter = new PHPFormatter();
                for (Int32 i = 0, n = lengths.Length; i < n; i++) {
                    String path = String.Format("{0}.dhp", lengths[i]);
                    Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(path);
                    dhParamsGen[lengths[i]] = formatter.Deserialize(stream);
                    stream.Close();
                }
            }
        }
        public static UInt32 GetNearest(UInt32 n) {
            Int32 j = 0;
            UInt32 m = (UInt32)Math.Abs(lengths[0] - n);
            for (Int32 i = 1; i < lengths.Length; i++) {
                UInt32 t = (UInt32)Math.Abs(lengths[i] - n);
                if (m > t) {
                    m = t;
                    j = i;
                }
            }
            return lengths[j];
        }

        public static Hashtable GetDHParams(UInt32 len) {
            AssocArray dhParams = (AssocArray)dhParamsGen[len];
            Random ran = new Random((Int32)DateTime.Now.Ticks);
            return ((AssocArray)dhParams[ran.Next(dhParams.Count)]).toHashtable();
        }
        public DHParams(UInt32 len) {
            length = DHParams.GetNearest(len);
            dhParams = DHParams.GetDHParams(length);
        }
        public UInt32 GetL() {
            return length;
        }
        public BigInteger GetP() {
            return BigInteger.Parse(PHPConvert.ToString(dhParams["p"]));
        }
        public BigInteger GetG() {
            return BigInteger.Parse(PHPConvert.ToString(dhParams["g"]));
        }
        public BigInteger GetX() {
            BigInteger x = BigInteger.GenerateRandom((Int32)length - 1);
            x.SetBit(length - 2);
            return x;
        }
        public Hashtable GetDHParams() {
            return dhParams;
        }
    }
}
#endif