############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# phprpc.py                                                #
#                                                          #
# Release 3.0.2                                            #
# Copyright by Team-PHPRPC                                 #
#                                                          #
# WebSite:  http://www.phprpc.org/                         #
#           http://www.phprpc.net/                         #
#           http://www.phprpc.com/                         #
#           http://sourceforge.net/projects/php-rpc/       #
#                                                          #
# Authors:  Ma Bingyao <andot@ujn.edu.cn>                  #
#                                                          #
# This file may be distributed and/or modified under the   #
# terms of the GNU Lesser General Public License (LGPL)    #
# version 3.0 as published by the Free Software Foundation #
# and appearing in the included file LICENSE.              #
#                                                          #
############################################################
#
# PHPRPC library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0.2
# LastModified: Mar 25, 2009
# This library is free.  You can redistribute it and/or modify it.

import base64, cgi, httplib, math, md5, phpformat, random, re
import sys, os, os.path, threading, time, traceback, types, urllib, xxtea

(__py_major__, __py_minor__) = sys.version_info[:2]
if (__py_major__ < 2) or ((__py_major__ == 2) and (__py_minor__ < 5)) :
    import urlparse25 as urlparse
else :
    import urlparse

class PHPRPC_Error(Exception):
    def __init__(self, number, message):
        self.number = number
        self.message = message
    def __str__(self):
        return "%i:%s" % (self.number, self.message)

class _Method:
    def __init__(self, invoke, name):
        self.__invoke = invoke
        self.__name = name
    def __call__(self, *args, **kargs):
        if kargs.has_key('byRef') :
            byRef = kargs['byRef']
        else :
            byRef = False
        if kargs.has_key('encryptmode') :
            encryptmode = kargs['encryptmode']
        else :
            encryptmode = None
        if kargs.has_key('callback') :
            callback = kargs['callback']
        else :
            callback = None
        return self.__invoke(self.__name, args, byRef, encryptmode, callback)

class _Proxy:
    def __init__(self, invoke):
        self.__invoke = invoke
    def __getattr__(self, name):
        return _Method(self.__invoke, name)

class _AsyncInvoke:
    def __init__(self, invoke, name, args, byRef, encryptmode, callback):
        self.__invoke = invoke
        self.__name = name
        self.__args = args
        self.__byRef = byRef
        self.__encryptmode = encryptmode
        self.__callback = callback
    def __call__(self):
        data = self.__invoke(self.__name, self.__args, self.__byRef, self.__encryptmode)
        self.__callback(data['result'], self.__args, data['output'], data['warning'])

class PHPRPC_Client(object):

    __cookie = ''
    __cookies = {}
    __sid = 0
    __cookielock = threading.RLock()
    __cookieslock = threading.RLock()

    def __init__(self, url = None):
        self.__clientID = "python_%s_%s_%s" % (PHPRPC_Client.__sid,
                                               random.randint(1 << 31, 1 << 32),
                                               math.floor(time.time()))
        PHPRPC_Client.__sid += 1
        if url != None:
            self.__urlstr = url
            self.__url = urlparse.urlsplit(url, 'http')
        else:
            self.__urlstr = ''
            self.__url = None
        self.__httpclients = []
        self.__key = None
        self.__keylength = 128
        self.__encryptmode = 0
        self.__keyexchanged = False
        self.__lock1 = threading.RLock()
        self.__lock2 = threading.RLock()
        self.__lock3 = threading.RLock()
        self.__proxy = None
        self.charset = 'utf-8'
        self.timeout = 30
        self.output = ''
        self.warning = None
        self.__server_version = None

    def __del__(self):
        self.__close()

    def __getattr__(self, name):
        return _Method(self.invoke, name)

    def invoke(self, name, args, byRef = False, encryptmode = None, callback = None):
        if callback == None:
            data = self.__invoke(name, args, byRef, encryptmode)
            self.warning = data['warning']
            self.output = data['output']
            return data['result']
        else:
            if type(callback) is types.StringType:
                callback = getattr(sys.modules['__main__'], callback, None)
            if not callable(callback):
                raise ValueError, "callback must be callable"
            threading.Thread(target = _AsyncInvoke(self.__invoke, name, args, byRef, encryptmode, callback)).start()

    def useService(self, url = None, username = None, password = None):
        if url != None:
            self.__close()
            self.__urlstr = url
            self.__url = urlparse.urlsplit(url, 'http')
            self.__key = None
            self.__keylength = 128
            self.__encryptmode = 0
            self.__keyexchanged = False
            self.charset = 'utf-8'
        if username != None:
            self.__url.username = username
        if password != None:
            self.__url.password = password
        return _Proxy(self.invoke)

    def setProxy(self, host, port = None, username = None, password = None):
        self.__close()
        if host == None:
            self.__proxy = None
        else:
            self.__proxy = urlparse.urlsplit(host)
            if port != None:
                self.__proxy.port = port
            if username != None:
                self.__proxy.username = username
            if password != None:
                self.__proxy.password = password

    proxy = property(fset = setProxy)

    def keylength():
        def fget(self):
            return self.__keylength
        def fset(self, value):
             if self.__key == None:
                 self.__keylength = value
        return locals()

    keylength = property(**keylength())

    def encryptmode():
        def fget(self):
            return self.__encryptmode
        def fset(self, value):
            if 0 <= value <= 3:
                self.__encryptmode = int(value)
            else:
                self.__encryptmode = 0
        return locals()

    encryptmode = property(**encryptmode())

    def __invoke(self, name, args, byRef, encryptmode):
        data = {'result' : None, 'warning' : None, 'output' : ''}
        try:
            try :
                if encryptmode == None:
                    encryptmode = self.__encryptmode
                self.__lock1.acquire()
                try:
                    encryptmode = self.__key_exchange(encryptmode)
                finally:
                    self.__lock1.release()
                result = self.__post("phprpc_func=%s&phprpc_args=%s&phprpc_encrypt=%s&phprpc_ref=%s" % (
                    name,
                    base64.b64encode(self.__encrypt(phpformat.serialize(args), 1, encryptmode)).replace('+', '%2B'),
                    encryptmode,
                    str(byRef).lower()
                ))
                if result.has_key('phprpc_errstr') and result.has_key('phprpc_errno'):
                    if (int(result['phprpc_errno']) == 0):
                        warning = None
                    else:
                        warning = PHPRPC_Error(int(result['phprpc_errno']), base64.b64decode(result['phprpc_errstr']))
                elif result.has_key('phprpc_functions'):
                    warning = PHPRPC_Error(1, "PHPRPC server haven't received the POST data!")
                else:
                    warning = PHPRPC_Error(1, "PHPRPC server occured unknown error!")
                data['warning'] = warning
                if result.has_key('phprpc_output'):
                    output = base64.b64decode(result['phprpc_output'])
                    if self.__server_version >= 3: output = self.__decrypt(output, 3, encryptmode)
                else:
                    output = ''
                data['output'] = output
                if result.has_key('phprpc_result'):
                    if result.has_key('phprpc_args'):
                        #arguments = phpformat.unserialize(self.__decrypt(base64.b64decode(result['phprpc_arg']), 1, encryptmode))
                        arguments = phpformat.unserialize(self.__decrypt(base64.b64decode(result['phprpc_args']), 1, encryptmode))
                        #for key in arguments: args[key] = arguments[key]
                        if isinstance(args, types.ListType) :
                            for key in arguments: args[key] = arguments[key]
                    data['result'] = phpformat.unserialize(self.__decrypt(base64.b64decode(result['phprpc_result']), 2, encryptmode))
                else:
                    data['result'] = warning
            except PHPRPC_Error, e:
                data['result'] = e
            except Exception, ex:
                if ex is types.StringType:
                    data['result'] = PHPRPC_Error(1, ex)
                else:
                    e = tuple(ex)
                    if (len(e) == 2) and (type(e[0]) is types.IntType) and (type(e[1]) is types.StringType):
                        data['result'] = PHPRPC_Error(e[0], e[1])
                    else:
                        data['result'] = PHPRPC_Error(1, str(ex))
        finally:
            return data

    def __close(self):
        self.__lock2.acquire()
        try:
            while len(self.__httpclients) > 0:
                httpclient = self.__httpclients.pop()
                httpclient.close()
        finally:
            self.__lock2.release()

    def __post(self, req):
        req = "phprpc_id=%s&%s" % (self.__clientID, req)
        headers = {
            'User-Agent' : "PHPRPC 3.0 Client for Python",
            'Cache-Control' : 'no-cache',
            'Content-Type' : "application/x-www-form-urlencoded; charset=%s" % self.charset,
            'Connection' : 'keep-alive',
        }
        PHPRPC_Client.__cookielock.acquire()
        try:
            if PHPRPC_Client.__cookie != '':
                headers['Cookie'] = PHPRPC_Client.__cookie
        finally:
            PHPRPC_Client.__cookielock.release()
        if (self.__url.username != None) and (self.__url.password != None):
            headers['Authorization'] = 'Basic %s' % base64.b64encode('%s:%s' %
                (self.__url.username, self.__url.password))
        if (self.__url.username != None) and (self.__url.password != None):
            headers['Proxy-Authorization'] = 'Basic %s' % base64.b64encode('%s:%s' %
                (self.__proxy.username, self.__proxy.password))
        self.__lock3.acquire()
        try:
            if len(self.__httpclients) == 0:
                if self.__proxy == None:
                    if self.__url.scheme == 'https':
                        httpclient = httplib.HTTPSConnection(self.__url.hostname, self.__url.port)
                    else:
                        httpclient = httplib.HTTPConnection(self.__url.hostname, self.__url.port)
                else:
                    if self.__proxy.scheme == 'https':
                        httpclient = httplib.HTTPSConnection(self.__proxy.hostname, self.__proxy.port)
                    else:
                        httpclient = httplib.HTTPConnection(self.__proxy.hostname, self.__proxy.port)
            else:
                httpclient = self.__httpclients.pop()
        finally:
            self.__lock3.release()
        if self.__proxy == None:
            path = urlparse.urlunsplit(('', '', self.__url.path, self.__url.query, self.__url.fragment))
        else:
            path = self.__urlstr
            headers['Proxy-Connection'] = 'keep-alive'
        httpclient.request('POST', path, req, headers)
        resp = httpclient.getresponse()
        if resp.status == 200:
            self.__lock3.acquire()
            try:
                self.__httpclients.append(httpclient)
            finally:
                self.__lock3.release()
            data = resp.read()
            x_powered_by = resp.getheader('x-powered-by', '')
            if x_powered_by != '':
                server_version = None
                for value in x_powered_by.split(','):
                    value = value.strip()
                    if value[0:13] == 'PHPRPC Server':
                        server_version = float(value[14:])
                if server_version == None:
                    raise PHPRPC_Error(1, 'Illegal PHPRPC server.')
                else:
                    self.__server_version = server_version
            else:
                raise PHPRPC_Error(1, 'Illegal PHPRPC server.')
            content_type = resp.getheader('content-type', '')
            if content_type != '':
                for value in content_type.split(','):
                    value = value.strip()
                    if value[0:20] == 'text/plain; charset=':
                        self.charset = value[20:]
            set_cookie = resp.getheader('set-cookie', '')
            if set_cookie != '':
                PHPRPC_Client.__cookieslock.acquire()
                try:
                    for value in set_cookie.split(','):
                        for pairs in value.split(';'):
                            pairs = pairs.strip()
                            pair = pairs.split('=', 1)
                            name = pair[0]
                            if pair[0] not in ('domain', 'expires', 'path', 'secure'):
                                PHPRPC_Client.__cookies[pair[0]] = pair
                    PHPRPC_Client.__cookie = '; '.join(
                        ('='.join(PHPRPC_Client.__cookies[name]) for name in PHPRPC_Client.__cookies)
                    )
                finally:
                    PHPRPC_Client.__cookieslock.release()
            result = {}
            for line in data.split(";\r\n"):
                if line != '':
                    (key, value) = line.split('=', 1)
                    result[key] = value[1:-1]
            return result
        else:
            httpclient.close()
            raise PHPRPC_Error(resp.status, resp.reason)

    def __key_exchange(self, encryptmode):
        if (self.__key != None) or (encryptmode == 0):
            return encryptmode
        if (self.__key == None) and (self.__keyexchanged):
            return 0
        result = self.__post("phprpc_encrypt=true&phprpc_keylen=%i" % self.__keylength)
        if result.has_key('phprpc_keylen') :
            self.__keylength = int(result['phprpc_keylen'])
        else :
            self.__keylength = 128
        if result.has_key('phprpc_encrypt'):
            encrypt = phpformat.unserialize(base64.b64decode(result['phprpc_encrypt']))
            x = random.randint(1 << (self.__keylength - 2), 1 << (self.__keylength - 1))
            key = pow(long(encrypt['y']), x, long(encrypt['p']))
            if self.__keylength == 128:
                key = hex(key)[2:-1].rjust(32, '0')
                self.__key = ''.join((chr(int(key[i*2:i*2+2], 16)) for i in xrange(16)))
            else:
                self.__key = md5.new(str(key)).digest()
            y = pow(long(encrypt['g']), x, long(encrypt['p']))
            self.__post('phprpc_encrypt=%s' % y)
        else:
            self.__key = None
            self.__keyexchanged = True
            self.__encryptmode = 0
            encryptmode = 0
        return encryptmode

    def __encrypt(self, s, level, encryptmode):
        #return (xxtea.encrypt(s, self.__key)
        #    if ((self.__key != None) and (encryptmode >= level))
        #    else s
        #)
        if ((self.__key != None) and (encryptmode >= level)) :
            result = xxtea.encrypt(s, self.__key)
        else :
            result = s
        return result

    def __decrypt(self, s, level, encryptmode):
        #return (xxtea.decrypt(s, self.__key)
        #    if ((self.__key != None) and (encryptmode >= level))
        #    else s
        #)
        if ((self.__key != None) and (encryptmode >= level)) :
            result = xxtea.decrypt(s, self.__key)
        else :
            result = s
        return result

class Request(object):
    def __init__(self, environ):
        self.environ = environ
        self.query = cgi.parse(fp = environ['wsgi.input'], environ = environ)

    def host_url(self):
        e = self.environ
        url = e['wsgi.url_scheme'] + '://'
        if e.get('HTTP_HOST'):
            host = e['HTTP_HOST']
            if ':' in host:
                host, port = host.split(':', 1)
            else:

                port = None
        else:
            host = e['SERVER_NAME']
            port = e['SERVER_PORT']
        if e['wsgi.url_scheme'] == 'https':
            if port == '443':
                port = None
        elif e['wsgi.url_scheme'] == 'http':
            if port == '80':
                port = None
        url += host
        if port:
            url += ':%s' % port
        return url
    host_url = property(host_url)

    def application_url(self):
        return self.host_url + urllib.quote(self.environ.get('SCRIPT_NAME', ''))
    application_url = property(application_url)

    def path_url(self):
        return self.application_url + urllib.quote(self.environ.get('PATH_INFO', ''))
    path_url = property(path_url)

    def url(self):
        params = []
        for key in self.query:
            if not key.lower().startswith('phprpc_'):
                for value in self.query[key]:
                    params.append('%s=%s' % (key, value))
        params = '&'.join(params)
        if params == '':
            return self.path_url
        else:
            return self.path_url + '?' + params
    url = property(url)

    def __len__(self):
        return len(self.query)

    def __iter__(self):
        return iter(self.query.keys())

    def __getitem__(self, key):
        if self.query.has_key(key):
            return self.query[key][0]
        else:
            return ''

    def has_key(self, key):
        return self.query.has_key(key)

class DHParams:

    lengths = [96, 128, 160, 192, 256, 512, 768, 1024, 1536, 2048, 3072, 4096]
    dhparams_gen = {}
    __dir__ = os.path.dirname(__file__)
    for length in lengths:
        dhparams_gen[length] = phpformat.unserialize(open("%s/dhparams/%s.dhp" % (__dir__, length), 'rb').read())

    def get_nearest(cls, n):
        j = 0
        m = abs(cls.lengths[0] - n)
        for i in xrange(len(cls.lengths)):
            t = abs(cls.lengths[i] - n)
            if m > t: (m, j) = (t, i)
        return cls.lengths[j]

    get_nearest = classmethod(get_nearest)

    def get(cls, length):
        length = cls.get_nearest(length)
        dhparams = cls.dhparams_gen[length]
        return [length, dhparams[random.randint(0, len(dhparams))]]

    get = classmethod(get)

class PHPRPC_WSGIApplication:
    def __init__(self, charset = 'utf-8', debug = False, sessionName = 'com.saddi.service.session'):
        self.__methods = {}
        self.charset = charset
        self.debug = debug
        self.sessionName = sessionName

    def __call__(self, environ, start_response = None):
        result = self.__call(environ)
        if start_response == None:
            return result
        start_response(result[0], result[1])
        return result[2]

    def add(self, method, aliasname = None):
        if type(method) is types.ListType:
            if aliasname == None:
                aliasname = []
                for m in method:
                    if type(m) is types.StringType:
                        aliasname.append(m)
                    else:
                        aliasname.append(m.__name__)
            if type(aliasname) is not types.ListType:
                raise TypeError, "aliasname's type should be list here"
            length = len(aliasname)
            if len(aliasname) != len(method):
                raise ValueError, "aliasname's size must equal methodname's size"
            for i in xrange(length):
                if type(method[i]) is types.StringType:
                    method[i] = getattr(sys.modules['__main__'], method[i], None)
                if not callable(method[i]):
                    raise ValueError, "method must be callable"
                if type(aliasname[i]) is not types.StringType:
                    raise TypeError, "aliasname element's type should be string"
                aliasname[i] = aliasname[i].lower()
                self.__methods[aliasname[i]] = method[i]
        else:
            if type(method) is types.StringType:
                method = getattr(sys.modules['__main__'], method, None)
            if not callable(method):
                raise ValueError, "method must be callable"
            if aliasname == None:
                aliasname = method.__name__
            if type(aliasname) is not types.StringType:
                raise TypeError, "aliasname's type should be string here"
            aliasname = aliasname.lower()
            self.__methods[aliasname] = method

    def __bool(self, s):
        return s.lower() != 'false'

    def __encrypt(self, s):
        s = s.lower()
        if s == 'true':
            return True
        if s == 'false':
            return False
        if s == '':
            return 0
        return int(s)

    def __args(self, s, key, encrypt):
        #return phpformat.dict_to_list(phpformat.unserialize(
        #    self.__decrypt_string(base64.b64decode(s), key, 1, encrypt)
        #)) if s else []
        result = []
        if s :
            result = phpformat.dict_to_list(phpformat.unserialize( self.__decrypt_string(base64.b64decode(s), key, 1, encrypt)))
        return result

    def __session(self, session, cid, hash = None):
        if hash:
            session[cid] = phpformat.serialize(hash)
        else:
            return phpformat.unserialize(session.get(cid, 'a:0:{}'))

    def __add_js_slashes(self, s, flag):
        r = range(1, 32) + [34, 39, 92, 127]
        if flag:
            r.extend(range(128, 256))
        out = []
        for c in s:
            #out.append('\\x%02x' % ord(c) if ord(c) in r else c)
            if ord(c) in r :
                out.append('\\x%02x' % ord(c))
            else :
                out.append(c)
        return ''.join(out)

    def __encode_string(self, s, encode = True, flag = True):
        if str == '':
            return str
        if encode:
            return base64.b64encode(s)
        else:
            return self.__add_js_slashes(s, flag)

    def __encrypt_string(self, s, key, level, encrypt):
        if (encrypt >= level):
            return xxtea.encrypt(s, key)
        else:
            return s

    def __decrypt_string(self, s, key, level, encrypt):
        if (encrypt >= level):
            return xxtea.decrypt(s, key)
        else:
            return s

    def __keylength(self, keylen, hash):
        if keylen:
            return int(keylen)
        else:
            if hash.has_key('keylen'):
                return hash['keylen']
            else:
                return 128

    def __key_exchange(self, body, sessionService, request, hash, callback, encode, encrypt, keylen):
        if encrypt == True:
            keylen, encrypt = DHParams.get(keylen)
            x = random.randint(1 << (keylen - 2), 1 << (keylen - 1))
            hash['x'] = str(x)
            hash['p'] = encrypt['p']
            hash['keylen'] = keylen
            encrypt['y'] = str(pow(long(encrypt['g']), x, long(encrypt['p'])))
            body.append('phprpc_encrypt="%s";' % self.__encode_string(phpformat.serialize(encrypt), encode))
            if keylen != 128:
                body.append('phprpc_keylen="%s";' % keylen)
            if sessionService:
                encodeURL = getattr(sessionService, 'encodeURL', None)
                if encodeURL:
                    sessionService.encodesSessionInURL = True
                    body.append('phprpc_url="%s";' % self.__encode_string(encodeURL(request.url), encode))
                    sessionService.encodesSessionInURL = False
        else:
            y = encrypt
            x = long(hash['x'])
            p = long(hash['p'])
            key = pow(y, x, p)
            if keylen == 128:
                key = hex(key)[2:-1].rjust(32, '0')
                hash['key'] = ''.join((chr(int(key[i*2:i*2+2], 16)) for i in xrange(16)))
            else:
                hash['key'] = md5.new(str(key)).digest()
        body.append(callback)

    def __write_functions(self, body, callback, encode):
        body.append('phprpc_functions="%s";' % self.__encode_string(phpformat.serialize(self.__methods.keys()), encode))
        body.append(callback)

    def __write_error(self, body, errno, errstr, callback, encode):
        body.append('phprpc_errno="%s";' % errno)
        body.append('phprpc_errstr="%s";' % self.__encode_string(errstr, encode, False))
        body.append('phprpc_output="";')
        body.append(callback)

    def __headers(self):
        english_weekdays = "Mon Tue Wed Thu Fri Sat Sun".split()
        english_months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split()
        def rfc1123():
        	date = time.gmtime()
        	return "%s, %02d %s %04d %02d:%02d:%02d GMT" % (english_weekdays[date[6]], date[2], english_months[date[1] - 1], date[0], date[3], date[4], date[5])

        return [
            ('X-Powered-By', 'PHPRPC Server/3.0'),
            ('P3P', 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"'),
            ('Expires', rfc1123()),
            ('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0'),
            ('Content-Type', "text/plain; charset=%s" % self.charset)
        ]

    def __call(self, environ):
        sessionService = environ.get(self.sessionName, None)
        if sessionService:
            session = getattr(sessionService, 'session', sessionService)
        else:
            session = None
        request = Request(environ)
        body = []
        callback = ''
        encode = True
        try:
            try :
                callback = base64.b64decode(request['phprpc_callback'])
                encode = self.__bool(request['phprpc_encode'])
                encrypt = self.__encrypt(request['phprpc_encrypt'])
                cid = "phprpc_%s" % (request['phprpc_id'] or '0')
                if request['phprpc_func']:
                    func = request['phprpc_func'].lower()
                    if self.__methods.has_key(func):
                        key = None
                        if session:
                            hash = self.__session(session, cid)
                            if hash.has_key('key'):
                                key = hash['key']
                            elif encrypt > 0:
                                encrypt = 0
                                raise Exception("Can't find the key for decryption.")
                        else:
                            encrypt = 0
                        ref = self.__bool(request['phprpc_ref'])
                        args = self.__args(request['phprpc_args'], key, encrypt)
                        if hasattr(self.__methods[func], 'func_code'):
                            func_code = self.__methods[func].func_code
                            has_session_args = (func_code.co_argcount > 0) and (func_code.co_varnames[func_code.co_argcount - 1] == 'session')
                            if has_session_args:
                                args.insert(func_code.co_argcount - 1, session)
                        result = self.__encode_string(self.__encrypt_string(
                            phpformat.serialize(self.__methods[func](*args)),
                        key, 2, encrypt), encode)
                        body.append('phprpc_result="%s";' % result)
                        if ref:
                            if has_session_args:
                                del args[func_code.co_argcount - 1]
                            args = self.__encode_string(self.__encrypt_string(
                                phpformat.serialize(args),
                            key, 1, encrypt), encode)
                            body.append('phprpc_args="%s";' % args)
                    else:
                        raise Exception("Can't find this function %s()." % func)
                    self.__write_error(body, 0, '', callback, encode)
                elif (encrypt != False) and (encrypt != 0) and (session != None):
                    hash = self.__session(session, cid)
                    keylen = self.__keylength(request['phprpc_keylen'], hash)
                    self.__key_exchange(body, sessionService, request, hash, callback, encode, encrypt, keylen)
                    self.__session(session, cid, hash)
                else:
                    self.__write_functions(body, callback, encode)
            except Exception, e:
                body = []
                if self.debug:
                    self.__write_error(body, 1, ''.join(traceback.format_exception(*sys.exc_info())), callback, encode)
                else:
                    self.__write_error(body, 1, e.message, callback, encode)
        finally:
            if session:
                if hasattr(session, 'save'):
                    session.save()
            return ['200 OK', self.__headers(), ['\r\n'.join(body)]]

class UrlMapMiddleware:
    def __init__(self, url_mapping):
        self.__init_url_mappings(url_mapping)

    def __init_url_mappings(self, url_mapping):
        self.__url_mapping = []
        for regexp, app in url_mapping:
            if not regexp.startswith('^'):
                regexp = '^' + regexp
            if not regexp.endswith('$'):
                regexp += '$'
            compiled = re.compile(regexp)
            self.__url_mapping.append((compiled, app))

    def __call__(self, environ, start_response = None):
        script_name = environ['SCRIPT_NAME']
        path_info = environ['PATH_INFO']
        path = urllib.quote(script_name) + urllib.quote(path_info)
        for regexp, app in self.__url_mapping:
            if regexp.match(path): return app(environ, start_response)
        if start_response:
            start_response('404 Not Found', [('Content-Type', "text/plain")])
            return ['404 Not Found']
        return ('404 Not Found', [('Content-Type', "text/plain")], ['404 Not Found'])

class PHPRPC_Server(object):
    def __init__(self, host = '', port = 80, app = None):
        self.host = host
        self.port = port
        if app == None:
            self.app = PHPRPC_WSGIApplication()
        else:
            self.app = app

    def add(self, method, aliasname = None):
        self.app.add(method, aliasname)

    def charset():
        def fget(self):
            return self.app.charset
        def fset(self, value):
            self.app.charset = value
        return locals()
    charset = property(**charset())

    def debug():
        def fget(self):
            return self.app.debug
        def fset(self, value):
            self.app.debug = value
        return locals()
    debug = property(**debug())

    def start(self):
        print "Serving on port %s:%s..." % (self.host, self.port)
        from wsgiref.simple_server import make_server
        httpd = make_server(self.host, self.port, self.app)
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            exit()
