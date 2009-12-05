{
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| IOCPTcpServer.pas                                        |
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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* IOCP TCP Server library.
 *
 * Copyright: Chen fei <cf850118@163.com>
 * Version: 3.0.2
 * LastModified: Sep 12, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
}

unit IOCPTcpServer;

interface

uses
  Windows, Classes, SysUtils, SyncObjs,
  WinSock, Winsock2;

const

  BufferSize = 4096;

type

  // Forward declarations

  TIOCPTCPServer = class;

  TSocketStatus = (ssSend, ssRecv);

  { TPerHandleData }

  PPerHandleData = ^TPerHandleData;
  TPerHandleData = record
    Overlapped: OVERLAPPED;
    WSABuffer:  TWsaBuf;
    Status:     TSocketStatus;
    Socket:     TSocket;
    Buffer:     array[0..BufferSize - 1] of AnsiChar;
  end;

  { TMemoryPool }

  TMemoryPool = class
  end;

  { TSocketError }

  TSocketError = class(Exception)
  private
    FErrorCode: Cardinal;
  public
    constructor Create(ErrorCode: Cardinal);
    class function ErrorCodeToString(ErrorCode: Cardinal): string; virtual;
    property ErrorCode: Cardinal read FErrorCode;
  end;

  { TConnection }

  TConnection = class
  private
    FClientSocket: TSocket;
    FData:         Pointer;
    FHasMoreData:  Boolean;
    FSendIOData:   PPerHandleData;
    FRecvIOData:   PPerHandleData;
    FRecvBytes:    Cardinal;
    FServer:       TIOCPTCPServer;
  public
    constructor Create(ClientSocket: TSocket; Server: TIOCPTCPServer);
    destructor Destroy; override;
    function Waiting: Boolean;
    function SendBuffer(const Buffer; ByteCount: Integer): Integer;
    property ClientSocket: TSocket read FClientSocket;
    property Data: Pointer read FData write FData;
    property HasMoreData: Boolean read FHasMoreData write FHasMoreData;
    property RecvIOData: PPerHandleData read FRecvIOData write FRecvIOData;
    property RecvBytes: Cardinal read FRecvBytes write FRecvBytes;
  end;

 { TIOCPTCPServer }

  TICOCPEvent = procedure(Sender: TIOCPTCPServer; Connection: TConnection) of object;

  TIOCPTCPServer = class(TComponent)
  private
    FActive:             Boolean;
    FConnections:        TThreadList;
    FDefaultPort:        Word;
    FListenPort:         THandle;
    FListenSocket:       TSocket;
    FListenAddr:         TSockAddrIn;
    FListenCount:        Word;
    FListenerThreads:    TThreadList;
    FProcessorCount:     Word;
    FProcessorThreads:   TThreadList;
    FLock:               TCriticalSection;
    FOnConnectEvent:     TICOCPEvent;
    FOnClientDisconnect: TICOCPEvent;
    FOnDataReceive:      TICOCPEvent;
    procedure SocketCheck(SocketResult: Integer);
    procedure SetActive(Value: Boolean);
  protected
    procedure DoDataReceive(Connection: TConnection); virtual;
    procedure DoConnect(Connection: TConnection); virtual;
    procedure DoDisconnect(Connection: TConnection); virtual;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure StartListening;
    procedure StopListening;
  published
    property Active: Boolean read FActive write SetActive default False;
    property DefaultPort: Word read FDefaultPort write FDefaultPort;
    property OnClientConnect: TICOCPEvent read FOnConnectEvent write FOnConnectEvent;
    property OnClientDisConnect: TICOCPEvent read FOnClientDisConnect write FOnClientDisConnect;
    property OnDataReceive: TICOCPEvent read FOnDataReceive write FOnDataReceive;
  end;

var
  WSData: TWSAData;

implementation

const

  ShutDownFlag = $FFFFFFFF;

type

  { TServerListener }

  TServerListener = class(TThread)
  private
    FServer: TIOCPTCPServer;
  protected
    procedure Execute; override;
  public
    constructor Create(Server: TIOCPTCPServer);
    destructor Destroy; override;
  end;

  { TServerProcessor }

  TServerProcessor = class(TThread)
  private
    FServer: TIOCPTCPServer;
  protected
    procedure Execute; override;
  public
    constructor Create(Server: TIOCPTCPServer);
    destructor Destroy; override;
  end;

{ IOData functions }

procedure NewIOData(var Data: PPerHandleData);
begin
  New(Data);
  FillChar(Data^, SizeOf(TPerHandleData), 0);
  Data.wsaBuffer.buf := Data.Buffer;
  Data.wsaBuffer.len := BufferSize;
end;

procedure FreeIOData(var Data: PPerHandleData);
begin
  if Assigned(Data) then
  begin
    FillChar(Data^, SizeOf(TPerHandleData), 0);
    Dispose(Data);
    Data := nil;
  end;
end;

procedure EmptyIOData(var Data: PPerHandleData);
begin
  if Assigned(Data) then
  begin
    FillChar(Data^.Overlapped, Sizeof(OVERLAPPED), 0);
    FillChar(Data^.Buffer, BufferSize, 0);
    Data^.WSABuffer.buf := Data^.Buffer;
    Data^.WSABuffer.len := BufferSize;
  end;
end;

{ TServerListener }

constructor TServerListener.Create(Server: TIOCPTCPServer);
begin
  inherited Create(True);
  FServer := Server;
  FreeOnTerminate := True;
  Priority := tpHighest;
  FServer.FListenerThreads.Add(Self);
  Resume;
end;

destructor TServerListener.Destroy;
begin
  FServer.FListenerThreads.Remove(Self);
  inherited;
end;

procedure TServerListener.Execute;
var
  AcceptSocket: TSocket;
  Connection: TConnection;
  Addr: TSockAddrIn;
  Len: Integer;
begin
  Addr := FServer.FListenAddr;
  Len := SizeOf(Addr);
  while not Terminated do
  begin
    AcceptSocket := accept(FServer.FListenSocket, @Addr, @Len);
    if AcceptSocket <> INVALID_SOCKET then
    begin
      Connection := TConnection.Create(AcceptSocket, FServer);
      FServer.DoConnect(Connection);
      Connection.Waiting;
    end
    else
    begin
      if WSAGetLastError = WSAEINTR then Break;
    end;
  end;
end;

{ TServerProcessor }

constructor TServerProcessor.Create(Server: TIOCPTCPServer);
begin
  inherited Create(True);
  FServer := Server;
  FreeOnTerminate := True;
  FServer.FProcessorThreads.Add(Self);
  Resume;
end;

destructor TServerProcessor.Destroy;
begin
  FServer.FProcessorThreads.Remove(Self);
  inherited;
end;

procedure TServerProcessor.Execute;
var
  HandleData: PPerHandleData;
  RecvBytes, Key: Cardinal;
  Connection: TConnection;
  ErrCode: Integer;
  List: TList;
begin
  while not Terminated do
  begin
    if not GetQueuedCompletionStatus(FServer.FListenPort, RecvBytes, Key, POverlapped(HandleData), INFINITE) then
    begin
      ErrCode := GetLastError;
      if ErrCode = ERROR_INVALID_HANDLE then Break;
      if ErrCode = ERROR_NETNAME_DELETED then
      begin
        List := FServer.FConnections.LockList;
        try
          if List.IndexOf(Pointer(Key)) > -1 then
          begin
            Connection := TConnection(Key);
            FServer.DoDisconnect(Connection);
            Connection.Free;
          end;
        finally
          FServer.FConnections.UnlockList;
        end;
      end;
      Continue;
    end;

    if (Key = 0) then
    begin
      if Cardinal(HandleData) = ShutDownFlag then Break;
      Continue;
    end;

    Connection := TConnection(Key);

    if (RecvBytes = 0) then
    begin
      FServer.DoDisconnect(Connection);
      Connection.Free;
      Continue;
    end;

    if HandleData.Status = ssRecv then
    begin
      Connection.RecvBytes := RecvBytes;
      FServer.DoDataReceive(Connection);
      Connection.Waiting;
    end;
  end;
end;

{ TSocketError }

constructor TSocketError.Create(ErrorCode: Cardinal);
begin
  FErrorCode := ErrorCode;
  inherited Create(ErrorCodeToString(ErrorCode));
end;

class function TSocketError.ErrorCodeToString(ErrorCode: Cardinal): string;
begin
  case ErrorCode of
    0:
      Result := '';
    WSAEINTR: {10004}
      Result := 'Interrupted system call';
    WSAEBADF: {10009}
      Result := 'Bad file number';
    WSAEACCES: {10013}
      Result := 'Permission denied';
    WSAEFAULT: {10014}
      Result := 'Bad address';
    WSAEINVAL: {10022}
      Result := 'Invalid argument';
    WSAEMFILE: {10024}
      Result := 'Too many open files';
    WSAEWOULDBLOCK: {10035}
      Result := 'Operation would block';
    WSAEINPROGRESS: {10036}
      Result := 'Operation now in progress';
    WSAEALREADY: {10037}
      Result := 'Operation already in progress';
    WSAENOTSOCK: {10038}
      Result := 'Socket operation on nonsocket';
    WSAEDESTADDRREQ: {10039}
      Result := 'Destination address required';
    WSAEMSGSIZE: {10040}
      Result := 'Message too long';
    WSAEPROTOTYPE: {10041}
      Result := 'Protocol wrong type for Socket';
    WSAENOPROTOOPT: {10042}
      Result := 'Protocol not available';
    WSAEPROTONOSUPPORT: {10043}
      Result := 'Protocol not supported';
    WSAESOCKTNOSUPPORT: {10044}
      Result := 'Socket not supported';
    WSAEOPNOTSUPP: {10045}
      Result := 'Operation not supported on Socket';
    WSAEPFNOSUPPORT: {10046}
      Result := 'Protocol family not supported';
    WSAEAFNOSUPPORT: {10047}
      Result := 'Address family not supported';
    WSAEADDRINUSE: {10048}
      Result := 'Address already in use';
    WSAEADDRNOTAVAIL: {10049}
      Result := 'Can''t assign requested address';
    WSAENETDOWN: {10050}
      Result := 'Network is down';
    WSAENETUNREACH: {10051}
      Result := 'Network is unreachable';
    WSAENETRESET: {10052}
      Result := 'Network dropped connection on reset';
    WSAECONNABORTED: {10053}
      Result := 'Software caused connection abort';
    WSAECONNRESET: {10054}
      Result := 'Connection reset by peer';
    WSAENOBUFS: {10055}
      Result := 'No Buffer space available';
    WSAEISCONN: {10056}
      Result := 'Socket is already connected';
    WSAENOTCONN: {10057}
      Result := 'Socket is not connected';
    WSAESHUTDOWN: {10058}
      Result := 'Can''t send after Socket shutdown';
    WSAETOOMANYREFS: {10059}
      Result := 'Too many references:can''t splice';
    WSAETIMEDOUT: {10060}
      Result := 'Connection timed out';
    WSAECONNREFUSED: {10061}
      Result := 'Connection refused';
    WSAELOOP: {10062}
      Result := 'Too many levels of symbolic links';
    WSAENAMETOOLONG: {10063}
      Result := 'File name is too long';
    WSAEHOSTDOWN: {10064}
      Result := 'Host is down';
    WSAEHOSTUNREACH: {10065}
      Result := 'No route to host';
    WSAENOTEMPTY: {10066}
      Result := 'Directory is not empty';
    WSAEPROCLIM: {10067}
      Result := 'Too many processes';
    WSAEUSERS: {10068}
      Result := 'Too many users';
    WSAEDQUOT: {10069}
      Result := 'Disk quota exceeded';
    WSAESTALE: {10070}
      Result := 'Stale NFS file handle';
    WSAEREMOTE: {10071}
      Result := 'Too many levels of remote in path';
    WSASYSNOTREADY: {10091}
      Result := 'Network subsystem is unusable';
    WSAVERNOTSUPPORTED: {10092}
      Result := 'Winsock DLL cannot support this application';
    WSANOTINITIALISED: {10093}
      Result := 'Winsock not initialized';
    WSAEDISCON: {10101}
      Result := 'Disconnect';
    WSAHOST_NOT_FOUND: {11001}
      Result := 'Host not found';
    WSATRY_AGAIN: {11002}
      Result := 'Non authoritative - host not found';
    WSANO_RECOVERY: {11003}
      Result := 'Non recoverable error';
    WSANO_DATA: {11004}
      Result := 'Valid name, no data record of requested type'
  else
    Result := 'Other Winsock error (' + IntToStr(ErrorCode) + ')';
  end;
end;

{ TConnection }

constructor TConnection.Create(ClientSocket: TSocket; Server: TIOCPTCPServer);
begin
  FClientSocket := ClientSocket;
  FServer := Server;
  NewIOData(FSendIOData);
  FSendIOData^.Status := ssSend;
  FSendIOData^.Socket := ClientSocket;
  NewIOData(FRecvIOData);
  FRecvIOData^.Status := ssRecv;
  FRecvIOData^.Socket := ClientSocket;
  CreateIoCompletionPort(ClientSocket, FServer.FListenPort, Cardinal(Self), 0);
  FServer.FConnections.Add(Self);
end;

destructor TConnection.Destroy;
begin
  FServer.FConnections.Remove(Self);
  if (ClientSocket <> INVALID_SOCKET) then CloseSocket(ClientSocket);
  FreeIOData(FSendIOData);
  FreeIOData(FRecvIOData);
  inherited;
end;

function TConnection.SendBuffer(const Buffer; ByteCount: Integer): Integer;
var
  SendBytes, Flags: Cardinal;
  SendResult: Integer;
  TotalBytes: Int64;
begin
  Flags := 0;
  TotalBytes := ByteCount;
  EmptyIOData(FSendIOData);
  FSendIOData^.WSABuffer.len := ByteCount;
  FSendIOData^.WSABuffer.buf := @Buffer;
  repeat
    SendResult := WSASend(FSendIOData^.Socket, @FSendIOData^.WSABuffer, 1,
      SendBytes, Flags, @FSendIOData^.Overlapped, nil);
    if SendResult = SOCKET_ERROR then
    begin
      if WSAGetLastError <> ERROR_IO_PENDING then
      begin
        Result := SOCKET_ERROR;
        Exit;
      end;
    end;
    Dec(TotalBytes, SendBytes);
    if (TotalBytes > 0) then
    begin
      FSendIOData^.WSABuffer.len := TotalBytes;
      FSendIOData^.WSABuffer.buf := Pointer(DWord(Buffer) + SendBytes);
    end;
  until TotalBytes <= 0;
  Result := ByteCount - TotalBytes;
end;

function TConnection.Waiting: Boolean;
var
  Flags: Cardinal;
begin
  Flags := 0;
  EmptyIOData(FRecvIOData);
  Result := WSARecv(FClientSocket, @FRecvIOData^.WSABuffer, 1, FRecvBytes,
    Flags, @FRecvIOData.Overlapped, nil) <> SOCKET_ERROR;
end;

{ TIOCPTCPServer }

constructor TIOCPTCPServer.Create(AOwner: TComponent);
var
  SystemInfo: TSystemInfo;
begin
  inherited Create(AOwner);
  GetSystemInfo(SystemInfo);
  FListenCount := SystemInfo.dwNumberOfProcessors * 2;
  FProcessorCount := SystemInfo.dwNumberOfProcessors * 2 + 2;
  FConnections := TThreadList.Create;
  FListenerThreads := TThreadList.Create;
  FProcessorThreads := TThreadList.Create;
  FLock := TCriticalSection.Create;
end;

destructor TIOCPTCPServer.Destroy;
var
  List: TList;
begin
  StopListening;

  FConnections.Free;

  while True do
  begin
    List := FListenerThreads.LockList;
    try
      if List.Count = 0 then Break;
    finally
      FListenerThreads.UnlockList;
    end;
    Sleep(50);
  end;
  FListenerThreads.Free;

  while True do
  begin
    List := FProcessorThreads.LockList;
    try
      if List.Count = 0 then Break;
    finally
      FProcessorThreads.UnlockList;
    end;
    Sleep(50);
  end;
  FProcessorThreads.Free;

  FLock.Free;
  inherited;
end;

procedure TIOCPTCPServer.SocketCheck(SocketResult: Integer);
begin
  if SocketResult = Integer(SOCKET_ERROR) then
    raise TSocketError.Create(WSAGetLastError);
end;

procedure TIOCPTCPServer.SetActive(Value: Boolean);
begin
  if FActive <> Value then
  begin
    if (csDesigning in ComponentState) or (csLoading in ComponentState) then
    begin
      FActive := Value;
    end
    else
    begin
      if Value then
        StartListening
      else
        StopListening;
    end;
  end;
end;

procedure TIOCPTCPServer.DoDataReceive(Connection: TConnection);
begin
  if Assigned(OnDataReceive) then OnDataReceive(Self, Connection);
end;

procedure TIOCPTCPServer.DoConnect(Connection: TConnection);
begin
  if Assigned(OnClientConnect) then OnClientConnect(Self, Connection);
end;

procedure TIOCPTCPServer.DoDisconnect(Connection: TConnection);
begin
  if Assigned(OnClientDisconnect) then OnClientDisconnect(Self, Connection);
end;

procedure TIOCPTCPServer.Loaded;
begin
  inherited;
  if Active then
  begin
    FActive := False;
    SetActive(True);
  end;
end;

procedure TIOCPTCPServer.StartListening;
var
  I: Integer;
begin
  if not FActive then
  begin
    try
      FListenPort := CreateIoCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);
      if FListenPort = 0 then
        raise Exception.Create(SysErrorMessage(GetLastError));

      FListenSocket := WSASocket(AF_INET, SOCK_STREAM, 0, nil, 0, WSA_FLAG_OVERLAPPED);
      if FListenSocket = INVALID_SOCKET then
        raise Exception.Create(SysErrorMessage(GetLastError));

      FillChar(FListenAddr, SizeOf(FListenAddr), 0);
      FListenAddr.sin_family := AF_INET;
      FListenAddr.sin_port := htons(FDefaultPort);
      FListenAddr.sin_addr.S_addr := INADDR_ANY;

      SocketCheck(bind(FListenSocket, FListenAddr, SizeOf(FListenAddr)));
      SocketCheck(listen(FListenSocket, MaxInt));

      for I := 0 to FProcessorCount - 1 do
      begin
        TServerProcessor.Create(Self);
      end;

      for I := 0 to FListenCount - 1 do
      begin
        TServerListener.Create(Self);
      end;

      FActive := True;
    except
      FActive := True;
      SetActive(False);
      raise;
    end;
  end;
end;

procedure TIOCPTCPServer.StopListening;
var
  I: Integer;
  List: TList;
begin
  if FActive then
  begin
    List := FConnections.LockList;
    try
      while List.Count > 0 do
        TConnection(List.Last).Free;
    finally
      FConnections.UnlockList;
    end;

    if FListenSocket <> INVALID_SOCKET then
    begin
      closesocket(FListenSocket);
      FListenSocket := INVALID_SOCKET;
    end;

    for I := 0 to FProcessorCount - 1 do
    begin
      PostQueuedCompletionStatus(FListenPort, 0, 0, Pointer(ShutDownFlag));
    end;

    if FListenPort <> 0 then
    begin
      CloseHandle(FListenPort);
      FListenPort := 0;
    end;

    FActive := False;
  end;
end;

initialization
  if WSAStartup(WINSOCK_VERSION, WSData) <> 0 then
    raise Exception.Create(SysErrorMessage(GetLastError));
finalization
  WSACleanup;
end.
