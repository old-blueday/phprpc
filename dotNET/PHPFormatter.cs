/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPFormatter.cs                                          |
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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHPFormatter class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Nov 7, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

namespace org.phprpc.util {
    using System;
    using System.IO;
    using System.Text;
    using System.Reflection;

    public sealed class PHPFormatter {

        private Encoding encoding;
        private Assembly[] assemblies;

        public PHPFormatter() {
            encoding = new UTF8Encoding();
#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT)
            assemblies = new Assembly[] { Assembly.GetCallingAssembly(), Assembly.GetExecutingAssembly() };
#else
            assemblies = AppDomain.CurrentDomain.GetAssemblies();
#endif
        }

        public PHPFormatter(Encoding encoding, Assembly[] assemblies) {
            this.encoding = encoding;
            this.assemblies = assemblies;
        }

        public Encoding Encoding {
            get {
                return encoding;
            }
            set {
                encoding = value;
            }
        }

        public Assembly[] Assemblies {
            get {
                return assemblies;
            }
            set {
                assemblies = value;
            }
        }

        public void Serialize(Stream serializationStream, Object graph) {
            PHPWriter phpWriter = new PHPWriter(serializationStream, encoding);
            phpWriter.Serialize(graph);
        }

        public Object Deserialize(Stream serializationStream) {
            PHPReader phpReader = new PHPReader(encoding, assemblies);
            return phpReader.Deserialize(serializationStream);
        }
    }
}
