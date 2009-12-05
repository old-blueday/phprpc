{ This file was automatically created by Lazarus. do not edit!
  This source is only used to compile and install the package.
 }

unit phprpclaz; 

interface

uses
BigInt, PHPRPC, XXTEA, LazarusPackageIntf;

implementation

procedure Register; 
begin
  RegisterUnit('PHPRPC', @PHPRPC.Register); 
end; 

initialization
  RegisterPackage('phprpclaz', @Register); 
end.
