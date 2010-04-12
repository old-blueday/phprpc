/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPSerializationTag.cs                                   |
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

/* PHPSerializationTag class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    internal sealed class PHPSerializationTag {
        public const int Quote = 34;
        public const int Zero = 48;
        public const int One = 49;
        public const int Colon = 58;
        public const int Semicolon = 59;
        public const int CustomObject = 67;
        public const int Null = 78;
        public const int Object = 79;
        public const int PointerReference = 82;
        public const int EscapedBinaryString = 83;
        public const int UnicodeString = 85;
        public const int Slash = 92;
        public const int AssocArray = 97;
        public const int Boolean = 98;
        public const int Double = 100;
        public const int Integer = 105;
        public const int Reference = 114;
        public const int BinaryString = 115;
        public const int LeftB = 123;
        public const int RightB = 125;

        private PHPSerializationTag() {
        }
    }
}
