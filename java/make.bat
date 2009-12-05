@echo off
mkdir classes
javac -source 1.2 -classpath lib\servlet-api.jar;lib\spring.jar -d classes org\phprpc\*.java org\phprpc\util\*.java org\phprpc\spring\remoting\*.java
jar cf phprpc_spring.jar dhparams -C classes .
del classes\org\phprpc\spring\remoting\*.class
rmdir classes\org\phprpc\spring\remoting
rmdir classes\org\phprpc\spring
jar cf phprpc.jar dhparams -C classes .
del classes\org\phprpc\util\DHParams.class
del classes\org\phprpc\PHPRPC_Server.class
del classes\org\phprpc\RemoteFunction.class
jar cf phprpc_client.jar -C classes .
del classes\org\phprpc\util\*.class
del classes\org\phprpc\*.class
rmdir classes\org\phprpc\util
rmdir classes\org\phprpc
rmdir classes\org
rmdir classes