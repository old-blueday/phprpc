{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| Winsock2.pas                                             |
|                                                          |
| Release 3.0.2                                            |
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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* Winsock2 API Interface Unit.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Sep 12, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
}

unit Winsock2;

interface

uses
  Windows, WinSock;

const
  WINSOCK_VERSION = $0202;
  WSA_FLAG_OVERLAPPED = $01;

type

  PWsaEvent = ^TWsaEvent;
  TWsaEvent = THandle;

  PWsaOverlapped = ^TWsaOverlapped;
  TWsaOverlapped = OVERLAPPED;

  PWsaBuf = ^TWsaBuf;
  TWsaBuf = record
    len: u_long;
    buf: PAnsiChar;
  end;

function __WSAFDIsSet(s: TSocket; var FDSet: TFDSet): Integer; stdcall;

function accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket; stdcall;
function bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer; stdcall;
function closesocket(s: TSocket): Integer; stdcall;
function connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
function ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer; stdcall;
function getpeername(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer;
function getsockname(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer;
function getsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar; var optlen: Integer): Integer; stdcall;
function htonl(hostlong: u_long): u_long; stdcall;
function htons(hostshort: u_short): u_short; stdcall;
function inet_addr(cp: PAnsiChar): u_long; stdcall;
function inet_ntoa(inaddr: TInAddr): PAnsiChar; stdcall;
function listen(s: TSocket; backlog: Integer): Integer; stdcall;
function ntohl(netlong: u_long): u_long; stdcall;
function ntohs(netshort: u_short): u_short; stdcall;
function recv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
function recvfrom(s: TSocket; var Buf; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
function select(nfds: Integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): Longint; stdcall;
function send(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
function sendto(s: TSocket; var Buf; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer; stdcall;
function setsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar; optlen: Integer): Integer; stdcall;
function shutdown(s: TSocket; how: Integer): Integer; stdcall;
function socket(af, Struct, protocol: Integer): TSocket; stdcall;

function gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt; stdcall;
function gethostbyname(name: PAnsiChar): PHostEnt; stdcall;
function gethostname(name: PAnsiChar; len: Integer): Integer; stdcall;
function getservbyport(port: Integer; proto: PAnsiChar): PServEnt; stdcall;
function getservbyname(name, proto: PAnsiChar): PServEnt; stdcall;
function getprotobynumber(proto: Integer): PProtoEnt; stdcall;
function getprotobyname(name: PAnsiChar): PProtoEnt; stdcall;

function WSAStartup(VersionRequired: Word; var WSData: TWSAData): Integer; stdcall;
function WSACleanup: Integer; stdcall;
procedure WSASetLastError(Error: Integer); stdcall;
function WSAGetLastError: Integer; stdcall;
function WSAIsBlocking: BOOL; stdcall;
function WSAUnhookBlockingHook: Integer; stdcall;
function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc; stdcall;
function WSACancelBlockingCall: Integer; stdcall;
function WSAAsyncGetServByName(HWindow: HWND; wMsg: u_int; ame, proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetServByPort( HWindow: HWND; wMsg, port: u_int; proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetProtoByName(HWindow: HWND; wMsg: u_int; name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetProtoByNumber(HWindow: HWND; wMsg: u_int; number: Integer; buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetHostByAddr(HWindow: HWND; wMsg: u_int; addr: PAnsiChar; len, Struct: Integer; buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSACancelAsyncRequest(AsyncTaskHandle: THandle): Integer; stdcall;
function WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;

function WSAAccept(s: TSocket; addr: PSockAddr; len: PInteger; Condition: Pointer; CallbackData: Cardinal): TSocket; stdcall;
function WSARecv(s: TSocket; Buf: PWsaBuf; BufCount: Cardinal; var BytesRecvd, Flags: Cardinal; Overlapped: PWsaOverlapped; CompletionRoutine: Pointer): Integer; stdcall;
function WSASend(s: TSocket; Buf: PWsaBuf; BufCount: Cardinal; var BytesSent: Cardinal; Flags: Cardinal; Overlapped: PWsaOverlapped; CompletionRoutine: Pointer): Integer; stdcall;
function WSASocketA(af, struct, protocol: Integer; ProtocolInfo: Pointer; g: Cardinal; Flags: Cardinal): TSocket; stdcall;
function WSASocketW(af, struct, protocol: Integer; ProtocolInfo: Pointer; g: Cardinal; Flags: Cardinal): TSocket; stdcall;
function WSASocket(af, struct, protocol: Integer; ProtocolInfo: Pointer; g: Cardinal; Flags: Cardinal): TSocket; stdcall;

implementation

const
{$ifdef unicode}
  AWSuffix = 'W';
{$else}
  AWSuffix = 'A';
{$endif}
  ws2_32 = 'ws2_32.dll';

function __WSAFDIsSet; external ws2_32 name '__WSAFDIsSet';
function accept; external ws2_32 name 'accept';
function bind; external ws2_32 name 'bind';
function closesocket; external ws2_32 name 'closesocket';
function connect; external ws2_32 name 'connect';
function ioctlsocket; external ws2_32 name 'ioctlsocket';
function getpeername; external ws2_32 name 'getpeername';
function getsockname; external ws2_32 name 'getsockname';
function getsockopt; external ws2_32 name 'getsockopt';
function htonl; external ws2_32 name 'htonl';
function htons; external ws2_32 name 'htons';
function inet_addr; external ws2_32 name 'inet_addr';
function inet_ntoa; external ws2_32 name 'inet_ntoa';
function listen; external ws2_32 name 'listen';
function ntohl; external ws2_32 name 'ntohl';
function ntohs; external ws2_32 name 'ntohs';
function recv; external ws2_32 name 'recv';
function recvfrom; external ws2_32 name 'recvfrom';
function select; external ws2_32 name 'select';
function send; external ws2_32 name 'send';
function sendto; external ws2_32 name 'sendto';
function setsockopt; external ws2_32 name 'setsockopt';
function shutdown; external ws2_32 name 'shutdown';
function socket; external ws2_32 name 'socket';
function gethostbyaddr; external ws2_32 name 'gethostbyaddr';
function gethostbyname; external ws2_32 name 'gethostbyname';
function gethostname; external ws2_32 name 'gethostname';
function getservbyport; external ws2_32 name 'getservbyport';
function getservbyname; external ws2_32 name 'getservbyname';
function getprotobynumber; external ws2_32 name 'getprotobynumber';
function getprotobyname; external ws2_32 name 'getprotobyname';
function WSAStartup; external ws2_32 name 'WSAStartup';
function WSACleanup; external ws2_32 name 'WSACleanup';
procedure WSASetLastError; external ws2_32 name 'WSASetLastError';
function WSAGetLastError; external ws2_32 name 'WSAGetLastError';
function WSAIsBlocking; external ws2_32 name 'WSAIsBlocking';
function WSAUnhookBlockingHook; external ws2_32 name 'WSAUnhookBlockingHook';
function WSASetBlockingHook; external ws2_32 name 'WSASetBlockingHook';
function WSACancelBlockingCall; external ws2_32 name 'WSACancelBlockingCall';
function WSAAsyncGetServByName; external ws2_32 name 'WSAAsyncGetServByName';
function WSAAsyncGetServByPort; external ws2_32 name 'WSAAsyncGetServByPort';
function WSAAsyncGetProtoByName; external ws2_32 name 'WSAAsyncGetProtoByName';
function WSAAsyncGetProtoByNumber; external ws2_32 name 'WSAAsyncGetProtoByNumber';
function WSAAsyncGetHostByName; external ws2_32 name 'WSAAsyncGetHostByName';
function WSAAsyncGetHostByAddr; external ws2_32 name 'WSAAsyncGetHostByAddr';
function WSACancelAsyncRequest; external ws2_32 name 'WSACancelAsyncRequest';
function WSAAsyncSelect; external ws2_32 name 'WSAAsyncSelect';

function WSAAccept; external ws2_32 name 'WSAAccept';
function WSARecv; external ws2_32 name 'WSARecv';
function WSASend; external ws2_32 name 'WSASend';
function WSASocketA; external ws2_32 name 'WSASocketA';
function WSASocketW; external ws2_32 name 'WSASocketW';
function WSASocket; external ws2_32 name 'WSASocket' + AWSuffix;

end.
