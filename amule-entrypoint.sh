#!/usr/bin/env bash

# Uncomment for debug
#set -x

AMULE_UID=${PUID:-1000}
AMULE_GID=${PGID:-1000}

AMULE_INCOMING=/incoming
AMULE_TEMP=/temp
AMULE_HOME=/home/amule/.aMule
AMULE_CONF=${AMULE_HOME}/amule.conf
REMOTE_CONF=${AMULE_HOME}/remote.conf

AMULE_GROUP="amule"
if grep -q ":${AMULE_GID}:" /etc/group; then
    echo "Group ${AMULE_GID} already exists. Won't be created."
    AMULE_GROUP=$(getent group "${AMULE_GID}" | cut -d: -f1)
    echo "Group ${AMULE_GROUP} with GID ${AMULE_GID} will be used as amule group."
else
    addgroup amule --gid "${AMULE_GID}"
fi

if grep -q ":${AMULE_UID}:" /etc/passwd; then
    echo "User ${AMULE_UID} already exists. Won't be added."
else
    adduser amule --uid "${AMULE_UID}" --gid "${AMULE_GID}" --shell "/sbin/nologin" --home "/home/amule" --no-create-home --disabled-password --gecos "First Last,RoomNumber,WorkPhone,HomePhone"
fi

if [ ! -d "${AMULE_INCOMING}" ]; then
    echo "Directory ${AMULE_INCOMING} does not exists. Creating ..."
    mkdir -p "${AMULE_INCOMING}"
fi

if [ ! -d "${AMULE_TEMP}" ]; then
    echo "Directory ${AMULE_TEMP} does not exists. Creating ..."
    mkdir -p "${AMULE_TEMP}"
fi

if [ ! -d ${AMULE_HOME} ]; then
    echo "${AMULE_HOME} directory NOT found. Creating directory ..."
    mkdir -p "${AMULE_HOME}"
fi

if [[ -z "${GUI_PWD}" ]]; then
    AMULE_GUI_PWD=$(pwgen -s 64)
else
    AMULE_GUI_PWD="${GUI_PWD}"
fi
AMULE_GUI_ENCODED_PWD=$(echo -n "${AMULE_GUI_PWD}" | md5sum | cut -d ' ' -f 1)

if [[ -z "${WEBUI_PWD}" ]]; then
    AMULE_WEBUI_PWD=$(pwgen -s 64)
else
    AMULE_WEBUI_PWD="${WEBUI_PWD}"
fi
AMULE_WEBUI_ENCODED_PWD=$(echo -n "${AMULE_WEBUI_PWD}" | md5sum | cut -d ' ' -f 1)

if [ ! -f ${AMULE_CONF} ]; then
    echo "Remote GUI password: ${AMULE_GUI_PWD}"
    echo "Web UI password: ${AMULE_WEBUI_PWD}"

    echo "${AMULE_CONF} file NOT found. Generating new default configuration ..."
    cat > ${AMULE_CONF} <<- EOM
[eMule]
AppVersion=2.3.3
Nick=http://www.aMule.org
QueueSizePref=50
MaxUpload=0
MaxDownload=0
SlotAllocation=2
Port=4662
UDPPort=4672
UDPEnable=1
Address=
Autoconnect=1
MaxSourcesPerFile=300
MaxConnections=500
MaxConnectionsPerFiveSeconds=20
RemoveDeadServer=0
DeadServerRetry=3
ServerKeepAliveTimeout=0
Reconnect=1
Scoresystem=1
Serverlist=0
AddServerListFromServer=0
AddServerListFromClient=0
SafeServerConnect=0
AutoConnectStaticOnly=0
UPnPEnabled=0
UPnPTCPPort=50000
SmartIdCheck=1
ConnectToKad=1
ConnectToED2K=1
TempDir=${AMULE_TEMP}
IncomingDir=${AMULE_INCOMING}
ICH=1
AICHTrust=0
CheckDiskspace=1
MinFreeDiskSpace=1
AddNewFilesPaused=0
PreviewPrio=0
ManualHighPrio=0
StartNextFile=0
StartNextFileSameCat=0
StartNextFileAlpha=0
FileBufferSizePref=16
DAPPref=1
UAPPref=1
AllocateFullFile=0
OSDirectory=${AMULE_HOME}
OnlineSignature=0
OnlineSignatureUpdate=5
EnableTrayIcon=0
MinToTray=0
ConfirmExit=1
StartupMinimized=0
3DDepth=10
ToolTipDelay=1
ShowOverhead=0
ShowInfoOnCatTabs=1
VerticalToolbar=0
GeoIPEnabled=1
VideoPlayer=
StatGraphsInterval=3
statsInterval=30
DownloadCapacity=300
UploadCapacity=100
StatsAverageMinutes=5
VariousStatisticsMaxValue=100
SeeShare=2
FilterLanIPs=1
ParanoidFiltering=1
IPFilterAutoLoad=1
IPFilterURL=http://upd.emule-security.org/ipfilter.zip
FilterLevel=127
IPFilterSystem=0
FilterMessages=1
FilterAllMessages=0
MessagesFromFriendsOnly=0
MessageFromValidSourcesOnly=1
FilterWordMessages=0
MessageFilter=
ShowMessagesInLog=1
FilterComments=0
CommentFilter=
ShareHiddenFiles=0
AutoSortDownloads=0
NewVersionCheck=0
AdvancedSpamFilter=1
MessageUseCaptchas=1
Language=
SplitterbarPosition=75
YourHostname=
DateTimeFormat=%A, %x, %X
AllcatType=0
ShowAllNotCats=0
SmartIdState=0
DropSlowSources=0
KadNodesUrl=http://upd.emule-security.org/nodes.dat
Ed2kServersUrl=http://upd.emule-security.org/server.met
ShowRatesOnTitle=0
GeoLiteCountryUpdateUrl=http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
StatsServerName=Shorty ED2K stats
StatsServerURL=http://ed2k.shortypower.dyndns.org/?hash=
CreateSparseFiles=1
[Browser]
OpenPageInTab=1
CustomBrowserString=
[Proxy]
ProxyEnableProxy=0
ProxyType=0
ProxyName=
ProxyPort=1080
ProxyEnablePassword=0
ProxyUser=
ProxyPassword=
[ExternalConnect]
UseSrcSeeds=0
AcceptExternalConnections=1
ECAddress=
ECPort=4712
ECPassword=${AMULE_GUI_ENCODED_PWD}
UPnPECEnabled=0
ShowProgressBar=1
ShowPercent=1
UseSecIdent=1
IpFilterClients=1
IpFilterServers=1
TransmitOnlyUploadingClients=0
[WebServer]
Enabled=1
Password=${AMULE_WEBUI_ENCODED_PWD}
PasswordLow=
Port=4711
WebUPnPTCPPort=50001
UPnPWebServerEnabled=0
UseGzip=1
UseLowRightsUser=0
PageRefreshTime=120
Template=AmuleWebUI-Reloaded
Path=amuleweb
[GUI]
HideOnClose=0
[Razor_Preferences]
FastED2KLinksHandler=1
[SkinGUIOptions]
Skin=
[Statistics]
MaxClientVersions=0
[Obfuscation]
IsClientCryptLayerSupported=1
IsCryptLayerRequested=1
IsClientCryptLayerRequired=0
CryptoPaddingLenght=254
CryptoKadUDPKey=138123518
[PowerManagement]
PreventSleepWhileDownloading=0
[UserEvents]
[UserEvents/DownloadCompleted]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/NewChatSession]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/OutOfDiskSpace]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[UserEvents/ErrorOnCompletion]
CoreEnabled=0
CoreCommand=
GUIEnabled=0
GUICommand=
[HTTPDownload]
URL_1=http://upd.emule-security.org/ipfilter.zip 
EOM
    echo "${AMULE_CONF} successfullly generated."
else
    echo "${AMULE_CONF} file found. Using existing configuration."
fi

if [ ! -f ${REMOTE_CONF} ]; then
    echo "Remote GUI password: ${AMULE_GUI_PWD}"
    echo "Web UI password: ${AMULE_WEBUI_PWD}"

    echo "${REMOTE_CONF} file NOT found. Generating new default configuration ..."
    cat > ${REMOTE_CONF} <<- EOM
Locale=
[EC]
Host=localhost
Port=4712
Password=${AMULE_GUI_ENCODED_PWD}
[Webserver]
Port=4711
UPnPWebServerEnabled=0
UPnPTCPPort=50001
Template=AmuleWebUI-Reloaded
UseGzip=1
AllowGuest=0
AdminPassword=${AMULE_WEBUI_ENCODED_PWD}
GuestPassword=
EOM
    echo "${REMOTE_CONF} successfullly generated."
else
    echo "${REMOTE_CONF} file found. Using existing configuration."
fi

chown -R "${AMULE_UID}:${AMULE_GID}" ${AMULE_INCOMING}
chown -R "${AMULE_UID}:${AMULE_GID}" ${AMULE_TEMP}
chown -R "${AMULE_UID}:${AMULE_GID}" ${AMULE_HOME}
sudo -H -u '#'"${AMULE_UID}" sh -c "amuled -c ${AMULE_HOME} -o"
